module Journey
  module Path
    class Pattern
      attr_reader :spec

      def initialize thing
        parser = Journey::Definition::Parser.new

        case thing
        when Regexp
          @spec = thing
          p :wtf => thing
        when String
          @spec = parser.parse thing
        else
          @spec = parser.parse thing.path
        end
      end

      def names
        @spec.find_all { |node|
          node.type == :SYMBOL
        }.map { |n| n.children.tr(':', '') }
      end

      class Matcher < Journey::Definition::Node::Visitor # :nodoc:
        def initialize scanner
          @scanner = scanner
          @contents = {}
          super()
        end

        def accept node
          return @contents if @scanner.eos?
          super
          @contents
        end

        def visit_SEGMENT node
          token, text = @scanner.next_token
          raise "wrong token [#{token}, #{text}]" unless token == :SLASH
          super
        end

        def visit_SYMBOL node
          token, text = @scanner.next_token
          @contents[node.to_sym] = text
          super
        end

        def visit_LITERAL node
          token, text = @scanner.next_token
          raise unless text == node.children
          super
        end

        def visit_DOT node
          token, text = @scanner.next_token
          raise unless token == node.type
          super
        end
      end

      def =~ other
        scanner = Journey::Definition::Scanner.new
        scanner.scan_setup other
        matcher = Matcher.new scanner
        matcher.accept spec
      end
    end
  end
end
