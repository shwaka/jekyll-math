# coding: utf-8
module JekyllMath
  class DataHandler
    @@data_key = :crossref
    def self.from_context(context)
      context = context
      site = context.registers[:site]
      current_page = site.pages.find{|page|
        current_page_path = context.registers[:page]["path"]
        page["path"] == current_page_path }
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
