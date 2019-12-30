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
        @data[:captions] ||= {}
        @captions = @data[:captions]
        @data[:label_for_caption] ||= nil
      end

      def add_caption(label, content)
        @data[:captions] ||= {}
        if @captions.has_key?(label)
          raise "Caption for the key '#{label}' is already defined"
        end
        @captions[label] = content
      end

      # def get_caption(label)
      #   return @captions[label]
      # end

      def replace_captions
        html = @page.output
        doc = Nokogiri::HTML.parse(html)
        doc.css(".#{@@theorem_class}").each do |elm|
          label = elm.attr("#{@@theorem_attr_prefix}-label")
          if @captions.has_key?(label)
            elm.css(".#{@@theorem_class}-caption-content").each do |elm_content|
              # 一つしかヒットしないはず
              elm_content.inner_html = @captions[label]
            end
          end
          # p @captions[label]
          # label = elm.attr("#{@@ref_attr_prefix}-label")
          # command = elm.attr("#{@@ref_attr_prefix}-command")
          # elm.content = self.ref_or_cref(command, label)
        end
        @page.output = doc.inner_html
      end

      def save_label(label)
        @data[:label_for_caption] = label
      end

      def load_label
        return @data[:label_for_caption]
      end
    end

    class CaptionBlock < Liquid::Block
      def initialize(tag_name, text, tokens)
        super
      end

      def render(context)
        content = super
        handler = CaptionHandler.from_context(context)
        label = handler.load_label
        handler.add_caption(label, content)
        return ""
      end
    end

    class TheoremBlock < Liquid::Block
      @@html_class = "theorem"
      @@attr_prefix = "theorem"

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
        plain = "#{key}-#{text}-#{Time.now}"
        md5 = Digest::MD5.hexdigest(plain)
        return "#{key}-#{md5}"
      end

      def save_label(context)
        # 後で caption block で使うために記録
        caption_handler = CaptionHandler.from_context(context)
        caption_handler.save_label(@label)
      end

      def render(context)
        content = super
        self.save_label(context)
        ref_handler = RefHandler.from_context(context)
        site = context.registers[:site]
        theorem_types = TheoremTypes.new(site)
        theorem_name = theorem_types.get_name(@theorem_key)
        ref_handler.add_label(@label, theorem_name)
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.div("class" => @@html_class,
                  "#{@@attr_prefix}-key" => @theorem_key,
                  "#{@@attr_prefix}-label" => @label){
            xml.div("class" => "#{@@html_class}-header"){
              xml.span(ref_handler.cref(@label),
                      "class" => "#{@@html_class}-name")
              if not @caption.nil?
                xml.span("class" => "#{@@html_class}-caption"){
                  xml.span("(",
                           "class" => "#{@@html_class}-caption-paren")
                  xml.span(@caption,
                           "class" => "#{@@html_class}-caption-content")
                  xml.span(")",
                           "class" => "#{@@html_class}-caption-paren")
                }
              end
            }
            xml.div("class" => "#{@@html_class}-content")
          }
        end
        xml_root = builder.doc.root
        xml_root.css(".#{@@html_class}-content").each do |node|
          # xml.div(content) としてしまうと，内部のhtmlがエスケープされてしまう
          node.inner_html = content
        end
        return xml_root.to_s
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
Jekyll::Hooks.register :pages, :post_render, priority: 30 do |page|
  # ref の置換より先にこっちをやりたいので，priority を大きく設定
  if [".md", ".html"].include?(page.ext)
    handler = JekyllMath::Crossref::CaptionHandler.from_page(page)
    handler.replace_captions
  end
end
