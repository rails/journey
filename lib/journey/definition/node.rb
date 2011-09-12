module Journey
  module Definition
    class Node # :nodoc:
      include Enumerable

      class Visitor # :nodoc:
        def accept node
          visit node
        end

        private

        def visit node
          send "visit_#{node.type}", node
        end

        def nary node
          node.children.each { |x| visit x }
        end
        alias :visit_GROUP :nary
        alias :visit_CAT :nary
        alias :visit_STAR :nary

        def terminal node; end
        alias :visit_LITERAL :terminal
        alias :visit_SYMBOL :terminal
        alias :visit_SLASH :terminal
        alias :visit_DOT :terminal
      end

      ##
      # Loop through the requirements AST
      class Each < Visitor # :nodoc:
        attr_reader :block

        def initialize block
          @block = block
        end

        def visit node
          block.call node
          super
        end
      end

      class String < Visitor
        private

        def visit_CAT node
          node.children.map { |x| visit x }.join
        end

        def visit_STAR node
          "*" + visit_CAT(node)
        end

        def terminal node
          node.children
        end
        alias :visit_SLASH :terminal
        alias :visit_LITERAL :terminal
        alias :visit_SYMBOL :terminal
        alias :visit_DOT :terminal

        def visit_GROUP node
          "(#{node.children.map { |x| visit x }.join})"
        end
      end

      attr_reader :children

      def initialize children = []
        @children = children
      end

      def each(&block)
        Each.new(block).accept(self)
      end

      def to_s
        String.new.accept(self)
      end

      def to_sym
        children.tr(':', '').to_sym
      end
    end

    %w{ Cat Group Star Symbol Slash Literal Dot }.each do |t|
      class_eval %{
        class #{t} < Node
          def type; :#{t.upcase}; end
        end
      }
    end
  end
end
