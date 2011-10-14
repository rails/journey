# encoding: utf-8
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

      def binary node
        visit node.left
        visit node.right
      end
      def visit_CAT(n); binary(n); end
      def visit_OR(n); binary(n); end

      def unary node
        visit node.value
      end
      def visit_GROUP(n); unary(n); end
      def visit_STAR(n); unary(n); end

      def terminal node; end
      %w{ LITERAL SYMBOL SLASH DOT }.each do |t|
        class_eval %{ def visit_#{t}(n); terminal(n); end }
      end
    end

    ##
    # Loop through the requirements AST
    class Each < Visitor # :nodoc:
      attr_reader :block

      def initialize block
        @block = block
      end

      def visit node
        super
        block.call node
      end
    end

    class String < Visitor
      private

      def binary node
        [visit(node.left), visit(node.right)].join
      end

      def terminal node
        node.value
      end

      def visit_STAR node
        "*" + super
      end

      def visit_GROUP node
        "(#{visit node.value})"
      end

      def visit_OR node
        [visit(node.left), visit(node.right)].join '|'
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
          visit node.value
        end
      end

      def terminal node
        node.value
      end

      def binary node
        [visit(node.left), visit(node.right)].join
      end

      def visit_SYMBOL node
        key = node.value.tr(':', '').to_sym

        if options.key? key
          value = options[key]
          consumed[key] = value
          Router::Utils.escape_uri(value)
        else
          "\0"
        end
      end
    end

    class Dot < Visitor
      def initialize
        @nodes = []
        @edges = []
      end

      def accept node
        super
        <<-eodot
digraph parse_tree {
  size="8,5"
  node [shape = none];
  edge [dir = none];
  #{@nodes.join "\n"}
  #{@edges.join("\n")}
}
        eodot
      end

      private
      def binary node
        node.children.each do |c|
          @edges << "#{node.object_id} -> #{c.object_id};"
        end
        super
      end

      def visit_GROUP node
        @nodes << "#{node.object_id} [label=\"()\"];"
        super
      end

      def visit_CAT node
        @nodes << "#{node.object_id} [label=\"○\"];"
        super
      end

      def visit_STAR node
        @nodes << "#{node.object_id} [label=\"*\"];"
        super
      end

      def visit_OR node
        @nodes << "#{node.object_id} [label=\"|\"];"
        super
      end

      def terminal node
        label = node.position && "(#{node.position})"
        value = [label, node.children].compact.join '\\n'

        @nodes << "#{node.object_id} [label=\"#{value}\"];"
      end
    end
  end
end
