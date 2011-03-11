module Rack
  class Router
    module Path
      class Pattern
        attr_reader :spec

        def initialize thing
          parser = Rack::Route::Definition::Parser.new

          case thing
          when Regexp
            @spec = thing
            p :wtf => thing
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
end
