module Rack
  class Router
    module Path
      class Pattern
        def initialize thing
          case thing
          when Regexp
            @thing = thing
            p :wtf => thing
          when String
            @thing = Regexp.new(thing)
          else
            @thing = thing
          end
        end

        def names
          @thing.names
        end
      end
    end
  end
end
