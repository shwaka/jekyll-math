# coding: utf-8
require "digest"
require "jekyll-math/crossref"
require "jekyll-math/parser"

module JekyllMath
  module Crossref
    class TheoremTypes
      @@config_key = "crossref"
      def initialize(site)
        @crossref_config = site.config[@@config_key]
      end

      def theorem_names
        return @crossref_config
      end

      def get_name(key)
        return self.theorem_names[key]
      end

      def keys
        return self.theorem_names.keys
      end
    end

    class CaptionHandler < ::JekyllMath::DataHandler
      @@theorem_class = "theorem" # TheoremBlock の @@html_class
      @@theorem_attr_prefix = "theorem" # TheoremBlock の @@attr_prefix
      def initialize(page)
        super
        @data[:caption_temp] ||= nil
      end

      def save_caption(caption)
        @data[:caption_temp] = caption
      end

      def clear_caption
        self.save_caption(nil)
      end

      def load_caption
        caption = @data[:caption_temp]
        self.clear_caption
        return caption
      end
    end

    class CaptionBlock < Liquid::Block
      def initialize(tag_name, text, tokens)
        super
      end

      def render(context)
        content = super
        handler = CaptionHandler.from_context(context)
        handler.save_caption(content)
        return ""
      end
    end

    class TheoremBlock < Liquid::Block
      @@html_class = "theorem"
      @@attr_prefix = "theorem"
      @@count_create_label = 0  # create_label での md5 ハッシュ値の衝突を回避するため

      def initialize(tag_name, text, tokens)
        @theorem_key = tag_name
        parser = ::JekyllMath::ArgParser.new(text)
        args = parser.args(0)
        kwargs = parser.kwargs(nil, ["label", "caption"])
        @label = kwargs["label"] || self.create_label(@theorem_key, text)
        @caption = kwargs["caption"]
        super
      end

      def create_label(key, text)
        @@count_create_label += 1
        plain = "#{key}-#{text}-#{@@count_create_label}"
        md5 = Digest::MD5.hexdigest(plain)
        return "#{key}-#{md5}"
      end

      def clear_caption(context)
        caption_handler = CaptionHandler.from_context(context)
        caption_handler.clear_caption
      end

      def load_caption(context)
        caption_handler = CaptionHandler.from_context(context)
        caption = caption_handler.load_caption
        # ↑caption がなければ，nil が返ってくる
        if @caption.nil?
          @caption = caption
        elsif not caption.nil?
          # caption=hoge と {% caption %} の両方で指定された場合
          raise "Duplicated caption specification: #{@caption}, #{caption}"
        end
      end

      def render(context)
        ref_handler = RefHandler.from_context(context)
        site = context.registers[:site]
        theorem_types = TheoremTypes.new(site)
        theorem_name = theorem_types.get_name(@theorem_key)
        # ↓add_label から get_caption_html までの5行は実行順序に注意．
        # - 内部にも相互参照がある場合にも正しい番号づけをするために，
        #   add_label は super より先に実行する必要がある．
        # - super 内で定義された caption を load するために，
        #   super は load_caption より先．
        # - 当然 load_caption は get_caption_html より先．
        # - clear_caption はもっと前でも多分大丈夫．
        ref_handler.add_label(@label, theorem_name)
        self.clear_caption(context)  # theorem の外で指定した caption を持ち込まないように
        content = super
        self.load_caption(context)
        caption_html = self.get_caption_html
        # ↑ここまでの5行の順序に注意
        name = ref_handler.cref(@label)
        return self._render(content, name, caption_html)
      end

      def _render(content, name, caption_html)
        # 最初は Nokogiri::XMl::Builder を使って生成していたけど，
        # (特に数式内の) escape 関連で色々と問題が起きたので，
        # 直接文字列として扱うことにした
        html = <<EOS
<div class="#{@@html_class}" #{@@attr_prefix}-key="#{@theorem_key}" #{@@attr_prefix}-label="#{@label}">
  <div class="#{@@html_class}-header">
    <span class="#{@@html_class}-name">#{name}</span>
    <span class="#{@@html_class}-caption">
#{caption_html}
    </span>
  </div>
  <div class="#{@@html_class}-content" markdown="block">
    #{content}
  </div>
</div>
EOS
        return html
      end

      def get_caption_html
        if @caption.nil?
          return ""
        end
        return <<EOS
      <span class="#{@@html_class}-caption-paren">(</span>
      <span class="#{@@html_class}-caption-content">#{@caption}</span>
      <span class="#{@@html_class}-caption-paren">)</span>
EOS
      end
    end

    class ProofBlock < Liquid::Block
      @@html_class = "proof"
      def initialize(tag_name, text, tokens)
        super
      end

      def render(context)
        content = super
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.div("class" => @@html_class){
            xml.div("証明",
                    "class" => "#{@@html_class}-header")
            xml.div("class" => "#{@@html_class}-content")
          }
        end
        xml_root = builder.doc.root
        xml_root.css(".#{@@html_class}-content").each do |node|
          node.inner_html = content
        end
        return xml_root.to_s
      end
    end
  end
end

Jekyll::Hooks.register :site, :post_read do |site|
  theorem_types = JekyllMath::Crossref::TheoremTypes.new(site)
  theorem_types.keys.each do |theorem_key|
    Liquid::Template.register_tag(theorem_key, JekyllMath::Crossref::TheoremBlock)
  end
end
Liquid::Template.register_tag('proof', JekyllMath::Crossref::ProofBlock)
Liquid::Template.register_tag('caption', JekyllMath::Crossref::CaptionBlock)
