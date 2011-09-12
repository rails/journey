require 'journey/visitors'

module Journey
  module Nodes
    class Node # :nodoc:
      include Enumerable

      attr_reader :children
      attr_accessor :position

      def initialize children = []
        @children = children
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

    %w{ Cat Group Star Or }.each do |t|
      class_eval %{
        class #{t} < Node
          def type; :#{t.upcase}; end
        end
      }
    end
  end
end
