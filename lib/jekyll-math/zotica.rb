# coding: utf-8

require 'pathname'
require 'nokogiri'
require 'zotica'

module JekyllMath
  module Zotica
    def self.convert(source)
      parser = ZoticaParser.new(source)
      parser.simple_math_macro_name = "m"
      parser.raw_macro_name = "raw"
      parser.resource_macro_name = "math-resource"
      parser.only_math = true
      parser.load_font(nil)
      document = parser.parse
      converter = ZenithalConverter.simple_html(document)
      output = converter.convert
      return self.add_span(output)
    end

    def self.add_span(math_html)
      # インライン数式を書こうとしたときに
      # kramdown によって勝手に <p> タグが追加されるのを防ぐ
      return "<span>#{math_html}</span>"
      # doc = Nokogiri::XML.parse(math_html)
      # doc.css("math-root").each do |root|
      #   root.set_attribute("markdown", "span")
      # end
      # return doc.inner_html
    end

    class ZoticaTag < Liquid::Tag
      def initialize(tag_name, text, tokens)
        super
        @text = text
      end

      def render(context)
        html = Zotica.convert(@text)
        return html
      end
    end
  end
end

Liquid::Template.register_tag('zotica', JekyllMath::Zotica::ZoticaTag)
