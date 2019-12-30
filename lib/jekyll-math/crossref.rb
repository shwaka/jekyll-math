# coding: utf-8
require 'nokogiri'
require 'jekyll-math/data-handler'

module JekyllMath
  module Crossref
    class RefHandler < ::JekyllMath::DataHandler
      @@ref_class = "crossref"
      @@ref_attr_prefix = "crossref"

      def initialize(page)
        super
        @data[:count] ||= 0
        @data[:labels] ||= {}
        @labels = @data[:labels]
      end

      def add_label(label, name)
        if @labels.has_key?(label)
          raise "Duplicated key: '#{label}'"
        end
        @labels[label] = {
          :number => self.get_number,
          :name => name
        }
      end

      def ref_or_cref(command, label)
        if not @labels.has_key?(label)
          path = @page.path
          msg = "label '#{label}' is not defined in #{path}"
          puts "Error: #{msg}"
          raise msg
        end
        if command == "ref"
          self.ref(label)
        elsif command == "cref"
          self.cref(label)
        else
          raise "invalid command: #{command}"
        end
      end

      def ref(label)
        return @labels[label]
      end

      def cref(label)
        name = @labels[label][:name]
        number = @labels[label][:number]
        return "#{name} #{number}"
      end

      def get_number
        @data[:count] += 1
        return @data[:count]
      end

      def ref_elm_str(command, label)
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.span(
            "crossref-#{command}: #{label}",
            "class" => @@ref_class,
            "#{@@ref_attr_prefix}-command" => command,
            "#{@@ref_attr_prefix}-label" => label
          )
        end
        return builder.doc.root.to_s
      end

      def replace_refs
        # html = @page.content
        html = @page.output
        doc = Nokogiri::HTML.parse(html)
        doc.css(".#{@@ref_class}").each do |elm|
          label = elm.attr("#{@@ref_attr_prefix}-label")
          command = elm.attr("#{@@ref_attr_prefix}-command")
          elm.content = self.ref_or_cref(command, label)
        end
        @page.output = doc.inner_html
      end
    end

    class LabelTag < Liquid::Tag
      def initialize(tag_name, text, tokens)
        super
        @label = text.strip
      end

      def render(context)
        handler = RefHandler.from_context(context)
        handler.add_label(@label, "定理")
        # return "label: #{@label}, cref: #{handler.cref(@label)}"
        return ""
      end
    end

    class RefTagBase < Liquid::Tag
      def initialize(tag_name, text, tokens, command)
        super(tag_name, text, tokens)
        @label = text.strip
        @command = command
      end

      def render(context)
        handler = RefHandler.from_context(context)
        return handler.ref_elm_str(@command, @label)
      end
    end

    class RefTag < RefTagBase
      def initialize(tag_name, text, tokens)
        super(tag_name, text, tokens, "ref")
      end
    end

    class CrefTag < RefTagBase
      def initialize(tag_name, text, tokens)
        super(tag_name, text, tokens, "cref")
      end
    end
  end
end

Liquid::Template.register_tag('label', JekyllMath::Crossref::LabelTag)
Liquid::Template.register_tag('ref', JekyllMath::Crossref::RefTag)
Liquid::Template.register_tag('cref', JekyllMath::Crossref::CrefTag)

Jekyll::Hooks.register :pages, :post_render, priority: 20 do |page|
  # theorem の caption との兼ね合いで priority が大事 (20はデフォルト値)
  if [".md", ".html"].include?(page.ext)
    handler = JekyllMath::Crossref::RefHandler.from_page(page)
    handler.replace_refs
  end
end
