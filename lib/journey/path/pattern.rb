module Journey
  module Path
    class Pattern
      attr_reader :spec

      def initialize thing
        parser = Journey::Definition::Parser.new

        case thing
        when Regexp
          @spec = thing
          p :wtf => thing
          puts "#" * 90
          puts caller
          puts "#" * 90
        when String
          @spec = parser.parse thing
        else
          @spec = parser.parse thing.path
        end
      end

      def names
        @spec.find_all { |node|
          node.type == :SYMBOL
        }.map { |n| n.children.tr(':', '') }
      end
    end
  end
end
