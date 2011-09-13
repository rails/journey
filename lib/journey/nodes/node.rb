require 'journey/visitors'

module Journey
  module Nodes
    class Node # :nodoc:
      include Enumerable

      attr_accessor :position, :value

      def initialize value
        @value    = value
        @position = nil
      end

      def each(&block)
        Visitors::Each.new(block).accept(self)
      end

      def to_s
        Visitors::String.new.accept(self)
      end

      def to_dot
        Visitors::Dot.new.accept(self)
      end

      def to_sym
        children.tr(':', '').to_sym
      end

      def terminal?
        false
      end
    end

    class Terminal < Node
      def children; value end

      def terminal?
        true
      end
    end

    %w{ Symbol Slash Literal Dot }.each do |t|
      class_eval %{
        class #{t} < Terminal
          def type; :#{t.upcase}; end
        end
      }
    end

    class Unary < Node
      def children; [value] end
    end

    class Group < Unary
      def type; :GROUP; end
    end

    class Star < Unary
      def type; :STAR; end
    end

    class Binary < Node
      alias :left :value
      attr_accessor :right

      def initialize left, right
        super(left)
        @right = right
      end

      def children; [left, right] end
    end

    class Cat < Binary
      def type; :CAT; end
    end

    class Or < Binary
      def type; :OR; end
    end
  end
end
