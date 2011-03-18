module Journey
  module Path
    class Pattern
      attr_reader :spec, :strexp

      def initialize strexp
        parser = Journey::Definition::Parser.new

        @strexp = strexp

        case strexp
        when String
          @spec   = parser.parse strexp
          @strexp = nil
        when Router::Strexp
          @spec   = parser.parse strexp.path
        else
          raise "wtf bro: #{strexp}"
        end
      end

      def names
        @spec.find_all { |node|
          node.type == :SYMBOL
        }.map { |n| n.children.tr(':', '') }
      end

      def to_regexp
        viz = ToRegexp.new(strexp.separators.join, strexp.requirements)
        viz.accept spec
      end

      class ToRegexp < Journey::Definition::Node::Visitor # :nodoc:
        def initialize separator, matchers
          @separator = separator
          @matchers  = matchers
          @separator_re = "[^#{separator}]+"
          super()
        end

        def visit_PATH node
          %r{\A#{node.children.map { |x| accept x }.join}\Z}
        end

        def visit_SEGMENT node
          "/" + node.children.map { |x| accept x }.join
        end

        def visit_SYMBOL node
          str = @separator_re
          if re = @matchers[node.to_sym]
            str = "#{re.source}?"
          end

          "(#{str})"
        end

        def visit_GROUP node
          "(?:#{node.children.map { |x| accept x }.join})?"
        end

        def visit_LITERAL node
          node.children
        end
      end

      class Matcher < Journey::Definition::Node::Visitor # :nodoc:
        class SyntaxError < ::SyntaxError
          def initialize expected, actual, pos, after
            super("unexpected '#{actual}', expected '#{expected}' at #{pos} after #{after}")
          end
        end

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
          unless token == :SLASH
            raise SyntaxError.new('/', text, @scanner.pos, @scanner.pre_match)
          end
          super
        end

        def visit_SYMBOL node
          _, text = @scanner.next_token
          @contents[node.to_sym] = text
          super
        end

        def visit_LITERAL node
          _, text = @scanner.next_token
          raise unless text == node.children
          super
        end

        def visit_DOT node
          token, text = @scanner.next_token
          unless token == node.type
            raise SyntaxError.new('.', text, @scanner.pos, @scanner.pre_match)
          end
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
