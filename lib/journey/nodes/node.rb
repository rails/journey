require 'journey/visitors'

module Journey
  module Nodes
    class Node # :nodoc:
      include Enumerable

      attr_accessor :left, :memo

      def initialize left
        @left = left
        @memo = nil
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

      DEFAULT_EXP = /[^\.\/\?]+/
      def initialize left
        super
        @regexp = DEFAULT_EXP
      end

      def default_regexp?
        regexp == DEFAULT_EXP
      end
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

    class Or < Node
      attr_reader :children

      def initialize children
        @children = children
      end

      def type; :OR; end
    end
  end
end
