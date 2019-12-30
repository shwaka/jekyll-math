# coding: utf-8

module JekyllMath
  # space, single/double quotes, backslash, equal の5つだけが特殊記号
  class ArgParser
    @@special_chars = [" ", "'", '"', "\\", "="]
    def initialize(text)
      @text = text
      @tokens = nil
      @args = nil
      @kwargs = nil
    end

    def args(num_req=nil, num_opt=0)
      # num_req 個の必須引数，num_opt 個のオプション引数
      if @args.nil?
        self.set_args
      end
      if not num_req.nil?
        len = @args.length
        if len < num_req
          raise "Error: too few arguments #{@args}, #{len} given, #{num_req} required"
        elsif len > num_req + num_opt
          raise "Error: too many arguments #{@args}, #{len} given, #{num_req+num_opt} allowed\n"
        end
      end
      return @args
    end

    def kwargs(keys_req=nil, keys_opt=nil)
      # keys_req, keys_opt: nil or list of strings
      # keys_req は必須 key，keys_opt はオプション key
      # 両方が nil なら，何もチェックしない
      if @kwargs.nil?
        self.set_args
      end
      keys = @kwargs.keys
      if not keys_req.nil?
        # 必須 key がちゃんとあるかチェック
        missing_keys = keys_req.select{|key| not keys.include?(key)}
        if missing_keys.length > 0
          raise "missing keys: #{missing_keys}"
        end
      end
      if not keys_opt.nil?
        # 余計な key がないかチェック
        allowed_keys = (keys_req || []) + keys_opt
        illegal_keys = keys.select{|key| not allowed_keys.include?(key)}
        if illegal_keys.length > 0
          raise "illegal keys: #{illegal_keys}"
        end
      end
      return @kwargs
    end

    def set_args
      @args = []
      @kwargs = {}
      num_tokens = self.tokens.length
      prev = nil
      key = nil
      (0...(num_tokens+1)).each do |n|
        if n < num_tokens
          token = self.tokens[n]
          if token == :equal
            if not prev.is_a?(String)
              # equal まわりが文法的に不正な場合
              # = hoge
              # hoge = fuga = piyo
              # hoge = = fuga
              raise "invalid format of arguments around '='"
            end
            key = prev
            prev = :equal
          else # :equal 以外の token を扱っているとき
            if prev == :equal
              if @kwargs.has_key?(key)
                raise "duplicate key: #{key}"
              end
              @kwargs[key] = token
              key = nil
              prev = nil
            else
              if not key.nil?
                raise "This can't happen!"
              end
              if prev.is_a?(String)
                @args.push(prev)
                prev = nil
              end
              prev = token
            end
          end
        else  # n == num_tokens
          if prev.is_a?(String)
            @args.push(prev)
          elsif prev == :equal
            raise "'=' cannot be the last token"
          end
        end
      end
    end

    def tokens
      # メモ化するために _tokens と分離
      if @tokens
        return @tokens
      else
        @tokens = self._tokens(0)
        return @tokens
      end
    end

    def _tokens(from)
      while (from < @text.length) and (@text[from] == " ") do
        from += 1
      end
      if from >= @text.length
        return []
      end
      token, end_of_token = self.get_token(from)
      return [token] + self._tokens(end_of_token)
    end

    def get_token(from)
      case @text[from]
      when " "
        raise "This can't happen!!!"
      when "="
        return :equal, from + 1
      # return @text[from], from + 1
      when "'", '"'
        quote_char = @text[from]
        token = ""
        escaped = false
        ind = from + 1
        while true do
          if ind == @text.length
            raise "syntax error: quote unclosed"
          end
          if escaped
            token += @text[ind]
            escaped = false
            ind += 1
            next
          end
          # 以下は escaped == false のときのみ実行される
          case @text[ind]
          when quote_char
            return token, ind + 1
          when "\\"
            escaped = true
            ind += 1
          else
            token += @text[ind]
            ind += 1
          end
        end
      when "\\"
        raise "syntax error"
      else
        # 普通の文字のとき
        end_of_token = from
        until (end_of_token == @text.length) or @@special_chars.include?(@text[end_of_token]) do
          end_of_token += 1
        end
        case @text[end_of_token]
        when " ", "=", nil        # nil は文字列末尾に到達したとき
          return @text[from...end_of_token], end_of_token
        when "'", '"', "\\"
          raise "syntax error"
        else
          raise "This can't happen!!!"
        end
      end
    end
  end
end
