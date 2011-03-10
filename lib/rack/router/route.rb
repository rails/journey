module Rack
  class Router
    class Route
      attr_reader :app, :path, :verb, :extras

      ##
      # +path+ is a path constraint.
      # +verb+ is a verb constraint.
      def initialize app, path, verb, extras = {}
        @app    = app
        @path   = path
        @verb   = verb
        @extras = extras
      end

      ##
      # Determines if this route object will connect given some constraint.
      def connects_to? constraints
        ex = extras.to_a
        (constraints.to_a & ex) == ex
      end
    end
  end
end
