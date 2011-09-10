module Journey
  module Definition
    class Node < Struct.new(:type, :children) # :nodoc:
      include Enumerable

      class Visitor # :nodoc:
        def accept node
          send "visit_#{node.type}", node
        end

        private

        def nary node
          node.children.each { |x| accept x }
        end
        alias :visit_PATH :nary
        alias :visit_DOT :nary
        alias :visit_SLASH :nary
        alias :visit_GROUP :nary

        def terminal node; end
        alias :visit_STAR :terminal
        alias :visit_LITERAL :terminal
        alias :visit_SYMBOL :terminal
      end

      ##
      # Loop through the requirements AST
      class Each < Visitor # :nodoc:
        attr_reader :block

        def initialize block
          @block = block
        end

        def accept node
          block.call node
          super
        end
      end

      class String < Visitor
        private

        def visit_PATH node
          node.children.map { |x| accept x }.join
        end

        def visit_STAR node
          "*" + node.children
        end

        def visit_DOT node
          "." + node.children.map { |x| accept x }.join
        end

        def visit_SLASH node
          "/" + node.children.map { |x| accept x }.join
        end

        def visit_LITERAL node
          node.children
        end

        def visit_SYMBOL node
          node.children
        end

        def visit_GROUP node
          "(#{node.children.map { |x| accept x }.join})"
        end
      end

      def initialize type, children = []
        super
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
  end
end
