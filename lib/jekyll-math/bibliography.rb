# coding: utf-8
require 'nokogiri'
require 'jekyll-math/data-handler'
require "jekyll-math/parser"

module JekyllMath
  module Bibliography
    class BibHandler < ::JekyllMath::DataHandler
      @@cite_class = "cite"
      @@cite_label_attr = "cite-label"
      @@bibitem_display_class = "bibitem-display"

      def initialize(page)
        super
        @data[:bibitems] ||= {}
        @bibitems = @data[:bibitems]
      end

      def add_bibitem(label, display)
        if @bibitems.has_key?(label)
          raise "Duplicate bib label: '#{label}'"
        end
        @bibitems[label] = display
      end

      def get_bibitem_display(label)
        display = @bibitems[label]
        return %(<span class="#{@@bibitem_display_class}">[#{display}]</span>)
      end

      def cite_elm_str(label)
        return <<EOS
<span class="#{@@cite_class}" #{@@cite_label_attr}="#{label}">
  cite: #{label}
</span>
EOS
      end

      def replace_cites
        html = @page.output
        doc = Nokogiri::HTML.parse(html)
        doc.css(".#{@@cite_class}").each do |elm|
          label = elm.attr(@@cite_label_attr)
          elm.inner_html = self.get_bibitem_display(label)
        end
        @page.output = doc.inner_html
      end
    end

    class CiteTag < Liquid::Tag
      def initialize(tag_name, text, tokens)
        parser = ::JekyllMath::ArgParser.new(text)
        args = parser.args(1)
        parser.kwargs([], [])   # kwargs are not allowed
        @label = args[0]
        super
      end

      def render(context)
        handler = BibHandler.from_context(context)
        return handler.cite_elm_str(@label)
      end
    end

    class BibitemBlock < Liquid::Block
      def initialize(tag_name, text, tokens)
        parser = ::JekyllMath::ArgParser.new(text)
        args = parser.args(2)
        parser.kwargs([], [])   # kwargs are not allowed
        @label = args[0]
        @display = args[1]
        super
      end

      def render(context)
        content = super
        handler = BibHandler.from_context(context)
        handler.add_bibitem(@label, @display)
        display = handler.get_bibitem_display(@label)
        return <<EOS
<div class="bibitem" markdown="1">
  #{display} #{content}
</div>
EOS
      end
    end

    class BibliographyBlock < Liquid::Block
      def render(context)
        content = super
        return <<EOS
<div class="bibliography">
#{content}
</div>
EOS
      end
    end
  end
end

Liquid::Template.register_tag('cite', JekyllMath::Bibliography::CiteTag)
Liquid::Template.register_tag('bibitem', JekyllMath::Bibliography::BibitemBlock)
Liquid::Template.register_tag('bibliography', JekyllMath::Bibliography::BibliographyBlock)
Jekyll::Hooks.register :pages, :post_render do |page|
  if [".md", ".html"].include?(page.ext)
    handler = JekyllMath::Bibliography::BibHandler.from_page(page)
    handler.replace_cites
  end
end
