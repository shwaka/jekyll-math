# coding: utf-8

require 'pathname'
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
      return output
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
