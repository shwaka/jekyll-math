# coding: utf-8

require 'nokogiri'
require 'zotica'
require "jekyll-math/parser"
require "jekyll-math/crossref"


module JekyllMath
  module Zotica
    def self.convert(source, mode, tag)
      parser = ZoticaSingleParser.new(source)
      # parser.simple_math_macro_name = "m"
      # parser.raw_macro_name = "raw"
      # parser.resource_macro_name = "math-resource"
      # parser.only_math = true
      parser.load_font(nil)
      document = parser.run
      converter = ZenithalConverter.simple_html(document)
      math_html = converter.convert
      if mode == :span
        return %(<span class="math-inline">#{math_html}</span>)
      elsif mode == :block
        return <<EOS
<div class="math-block">
#{math_html}
<span class="math-tag">#{tag}</span>
</div>
EOS
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
        @label = kwargs["label"]
        if args.length == 0
          @mode = :block
        else
          case args[0]
          when "inline"
            @mode = :span
            if not @label.nil?
              raise "label is not allowed in inline math"
            end
          when "block"
            @mode = :block
          else
            raise "Invalid argument: '#{args[0]}' (inline or block)"
          end
        end
      end

      def render(context)
        content = super
        if @label.nil?
          tag = nil
        else
          handler = ::JekyllMath::Crossref::RefHandler.from_context(context)
          handler.add_label(@label, :equation)
          tag = handler.cref(@label)
        end
        html = ::JekyllMath::Zotica.convert(content, @mode, tag)
        return html
      end
    end
  end
end

Liquid::Template.register_tag('zotica', JekyllMath::Zotica::ZoticaBlock)
