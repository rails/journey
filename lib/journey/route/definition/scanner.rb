require 'strscan'

module Journey
  module Route
    module Definition
      class Scanner
        def initialize
          @ss = nil
        end

        def scan_setup str
          @ss = StringScanner.new str
        end

        def next_token
          return if @ss.eos?

          until token = scan || @ss.eos?; end
          token
        end

        private
        def scan
          case
          # /
          when text = @ss.scan(/\//)
            [:SLASH, text]
          when text = @ss.scan(/\*/)
            [:STAR, text]
          when text = @ss.scan(/\(/)
            [:LPAREN, text]
          when text = @ss.scan(/\)/)
            [:RPAREN, text]
          when text = @ss.scan(/\./)
            [:DOT, text]
          when text = @ss.scan(/:\w+/)
            [:SYMBOL, text]
          when text = @ss.scan(/\w+/)
            [:LITERAL, text]
          # any char
          when text = @ss.scan(/./)
            [text, text]
          end
        end
      end
    end
  end
end
