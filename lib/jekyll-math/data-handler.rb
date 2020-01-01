# coding: utf-8
require 'pathname'

module JekyllMath
  class DataHandler
    @@data_key = :crossref
    def self.from_context(context)
      context = context
      site = context.registers[:site]
      pages = site.collection_names.inject(site.pages){|_pages,col_name|
        _pages + site.collections[col_name].docs
      }
      site_source_path = Pathname.new(site.source)
      current_page_path = site_source_path / context.registers[:page]["path"]
      current_page = pages.find{|page|
        path = site_source_path / page.path
        # ↑元々 page.path が絶対パスなら，path = page.path となる
        current_page_path == path
      }
      return self.new(current_page)
    end

    def self.from_page(page)
      return self.new(page)
    end

    def initialize(page)
      # ↓page 内に複数の label を書いたときは，
      # 最初は @@data_key は未定義，それ以降は定義済みになる
      @page = page
      @page.data[@@data_key] ||= {}
      @data = @page.data[@@data_key]
    end
  end
end
