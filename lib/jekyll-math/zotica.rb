# coding: utf-8

require 'nokogiri'
require 'zotica'
require "jekyll-math/parser"

module JekyllMath
  module Zotica
    def self.convert(source, mode)
      parser = ZoticaParser.new(source)
      parser.simple_math_macro_name = "m"
      parser.raw_macro_name = "raw"
      parser.resource_macro_name = "math-resource"
      parser.only_math = true
      parser.load_font(nil)
      document = parser.parse
      converter = ZenithalConverter.simple_html(document)
      math_html = converter.convert
      if mode == :span
        return %(<span class="math-inline">#{math_html}</span>)
      elsif mode == :block
        return %(<div class="math-block">\n#{math_html}\n</div>)
      else
        raise "Not implemented"
      end
    end

    class ZoticaBlock < Liquid::Block
      def initialize(tag_name, text, tokens)
        super
        parser = ::JekyllMath::ArgParser.new(text)
        args = parser.args(0, 1)
        kwargs = parser.kwargs(nil, ["label"])
        if args.length == 0
          @mode = :block
        else
          case args[0]
          when "inline"
            @mode = :span
          when "block"
            @mode = :block
          else
            raise "Invalid argument: '#{args[0]}' (inline or block)"
          end
        end
        @label = kwargs["label"]
      end

      def render(context)
        content = super
        html = ::JekyllMath::Zotica.convert(content, @mode)
        return html
      end
    end
  end
end

Liquid::Template.register_tag('zotica', JekyllMath::Zotica::ZoticaBlock)
