# coding: utf-8
require "jekyll-math/crossref"

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

  class TheoremTagBlock < Liquid::Block
    @@html_class = "theorem"
    @@attr_prefix = "theorem"

    def initialize(tag_name, text, tokens)
      @label = text.strip
      @theorem_key = tag_name
      super
    end

    def render(context)
      content = super
      handler = DataHandler.from_context(context)
      site = context.registers[:site]
      theorem_types = TheoremTypes.new(site)
      theorem_name = theorem_types.get_name(@theorem_key)
      handler.add_label(@label, theorem_name)
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.div("class" => @@html_class,
                "#{@@attr_prefix}-key" => @theorem_key){
          xml.div(handler.cref(@label),
                  "class" => "#{@@html_class}-header")
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

  class ProofTagBlock < Liquid::Block
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

Jekyll::Hooks.register :site, :post_read do |site|
  theorem_types = Crossref::TheoremTypes.new(site)
  theorem_types.keys.each do |theorem_key|
    Liquid::Template.register_tag(theorem_key, Crossref::TheoremTagBlock)
  end
end
Liquid::Template.register_tag('proof', Crossref::ProofTagBlock)
