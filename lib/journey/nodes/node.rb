require 'journey/visitors'
require 'forwardable'

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

      def nullable?
        raise ArgumentError, 'unknown nullable: %s' % self.class.name
      end

      def firstpos
        raise ArgumentError, 'unknown firstpos: %s' % self.class.name
      end

      def lastpos
        raise ArgumentError, 'unknown lastpos: %s' % self.class.name
      end

      def symbol?; false; end
      def literal?; false; end
    end

    class Terminal < Node
      alias :symbol :left

      def nullable?
        !left
      end

      def firstpos
        @wrapped_self ||= [self]
        left && @wrapped_self
      end
      alias :lastpos :firstpos
    end

    class Literal < Terminal
      def literal?; true; end
      def type; :LITERAL; end
    end

    class Dummy < Literal
      def initialize x = Object.new
        super
      end

      def literal?; false; end
    end

    %w{ Symbol Slash Dot }.each do |t|
      class_eval <<-eoruby, __FILE__, __LINE__ + 1
        class #{t} < Terminal;
          def type; :#{t.upcase}; end
        end
      eoruby
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

      def symbol?; true; end
    end

    class Unary < Node
      extend Forwardable
      def children; [left] end
      def_delegators :left, :nullable?, :firstpos, :lastpos
    end

    class Group < Unary
      def type; :GROUP; end

      def nullable?
        true
      end
    end

    class Star < Unary
      extend Forwardable
      def_delegators :left, :firstpos, :lastpos
      def type; :STAR; end

      def nullable?
        true
      end
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
        left.nullable? and right.nullable?
      end

      def firstpos
        @firstpos ||= begin
          if left.nullable?
            left.firstpos | right.firstpos
          else
            left.firstpos
          end
        end
      end

      def lastpos
        @lastpos ||= begin
          if right.nullable?
            left.lastpos | right.lastpos
          else
            right.lastpos
          end
        end
      end
    end

    class Or < Node
      attr_reader :children

      def initialize children
        @children = children
      end

      def type; :OR; end

      def nullable?
        @nullable = children.any?(&:nullable?) if @nullable.nil?
      end

      def firstpos
        @firstpos ||= children.map(&:firstpos).flatten.uniq
      end

      def lastpos
        @lastpos ||= children.map(&:lastpos).flatten.uniq
      end
    end
  end
end
