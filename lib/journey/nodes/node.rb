require 'journey/visitors'

module Journey
  module Nodes
    class Node # :nodoc:
      include Enumerable

      attr_accessor :left

      def initialize left
        @left = left
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
        name.to_sym
      end

      def name
        left.tr ':', ''
      end

      def type
        raise NotImplementedError
      end
    end

    class Terminal < Node
      alias :symbol :left
    end

    %w{ Symbol Slash Literal Dot }.each do |t|
      class_eval %{
        class #{t} < Terminal
          def type; :#{t.upcase}; end
        end
      }
    end

    class Symbol < Terminal
      attr_accessor :regexp
      alias :symbol :regexp

      def initialize left
        super
        @regexp = /[^\.\/\?]+/
      end
    end

    class Unary < Node
      def children; [value] end
      def nullable?; value.nullable? end
      def firstpos; value.firstpos end
      def lastpos; value.lastpos end
    end

    class Group < Unary
      def type; :GROUP; end

      def nullable?; true end
    end

    class Star < Unary
      def type; :STAR; end
    end

    class Binary < Node
      attr_accessor :right

      def initialize left, right
        super(left)
        @right = right
      end

      def children; [left, right] end
    end

    class Cat < Binary
      def type; :CAT; end
      def nullable?
        left.nullable? && right.nullable?
      end

      def firstpos
        if left.nullable?
          left.firstpos | right.firstpos
        else
          left.firstpos
        end
      end

      def lastpos
        if right.nullable?
          left.firstpos | right.firstpos
        else
          right.firstpos
        end
      end
    end

    class Or < Binary
      def type; :OR; end

      def nullable?
        left.nullable? || right.nullable?
      end

      def firstpos
        left.firstpos | right.firstpos
      end

      def lastpos
        left.lastpos | right.lastpos
      end
    end
  end
end
