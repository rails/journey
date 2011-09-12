module Journey
  module Visitors
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

    ###
    # Used for formatting urls (url_for)
    class Formatter < Visitor
      attr_reader :options, :consumed

      def initialize options
        @options  = options
        @consumed = {}
      end

      private
      def visit_GROUP node
        if consumed == options
          nil
        else
          node.children.map { |x| visit x }
        end
      end

      def terminal node
        node.children
      end
      alias :visit_SLASH :terminal
      alias :visit_LITERAL :terminal
      alias :visit_DOT :terminal

      def visit_CAT node
        node.children.map { |c| visit c }.join
      end

      alias :visit_STAR :visit_CAT

      def visit_SYMBOL node
        key = node.children.tr(':', '').to_sym

        if options.key? key
          consumed[key] = options[key]
        else
          "\0"
        end
      end
    end

  end
end
