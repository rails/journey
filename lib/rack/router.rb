require 'rack/router/utils'
require 'rack/router/strexp'

module Rack
  class Router
    VERSION = '1.0.0'

    def initialize options
      @options = options
    end

    def add_route app, conditions, defaults, name
    end

    class RegexpWithNamedGroups
      def initialize thing
        case thing
        when Regexp, String
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

  Mount = Router
  Mount::RouteSet = Router
end
