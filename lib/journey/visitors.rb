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

      def nary node
        node.children.each { |x| visit x }
      end
      %w{ GROUP CAT STAR OR }.each do |t|
        class_eval %{ def visit_#{t}(n); nary(n); end }
      end

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
        block.call node
        super
      end
    end

    class String < Visitor
      private

      def nary node
        node.children.map { |x| visit x }.join
      end

      def visit_STAR node
        "*" + super
      end

      def terminal node
        node.children
      end

      def visit_GROUP node
        "(#{node.children.map { |x| visit x }.join})"
      end

      def visit_OR node
        node.children.map { |x| visit x }.join '|'
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

      def nary node
        node.children.map { |c| visit c }.join
      end

      def visit_SYMBOL node
        key = node.children.tr(':', '').to_sym

        if options.key? key
          consumed[key] = options[key]
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
      def nary node
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
