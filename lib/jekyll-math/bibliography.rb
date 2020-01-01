# coding: utf-8
require 'nokogiri'
require 'jekyll-math/data-handler'
require "jekyll-math/parser"

module JekyllMath
  module Bibliography
    class BibHandler < ::JekyllMath::DataHandler
      @@cite_class = "cite"
      @@cite_attr_prefix = "cite"
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

      def get_bibitem_display(label, comment="")
        text = @bibitems[label]
        if text.nil?
          raise "Bibitem not found: '#{label}'"
        end
        if comment.length > 0
          text += ", #{comment}"
        end
        return %(<span class="#{@@bibitem_display_class}">[#{text}]</span>)
      end

      def cite_elm_str(label, comment="")
        # TODO: comment は escape した方が良い？
        return <<EOS
<span class="#{@@cite_class}"
      #{@@cite_attr_prefix}-label="#{label}"
      #{@@cite_attr_prefix}-comment="#{comment}">
  cite: #{label}
</span>
EOS
      end

      def replace_cites
        html = @page.output
        doc = Nokogiri::HTML.parse(html)
        doc.css(".#{@@cite_class}").each do |elm|
          label = elm.attr("#{@@cite_attr_prefix}-label")
          comment = elm.attr("#{@@cite_attr_prefix}-comment")
          elm.inner_html = self.get_bibitem_display(label, comment)
        end
        @page.output = doc.inner_html
      end
    end

    class CiteTag < Liquid::Tag
      def initialize(tag_name, text, tokens)
        parser = ::JekyllMath::ArgParser.new(text)
        args = parser.args(1, 1)
        parser.kwargs([], [])   # kwargs are not allowed
        @label = args[0]
        @comment = args[1]
        super
      end

      def render(context)
        handler = BibHandler.from_context(context)
        return handler.cite_elm_str(@label, @comment)
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
  if [".md", ".html"].include?(page.ext) # page.data["ext"] は nil
    handler = JekyllMath::Bibliography::BibHandler.from_page(page)
    handler.replace_cites
  end
end
Jekyll::Hooks.register :documents, :post_render do |doc|
  if [".md", ".html"].include?(doc.data["ext"])
    handler = JekyllMath::Bibliography::BibHandler.from_page(doc)
    handler.replace_cites
  end
end
