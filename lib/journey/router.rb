require 'journey/router/utils'
require 'journey/router/strexp'
require 'journey/definition/parser'
require 'journey/route'
require 'journey/path/pattern'

require 'journey/backwards' # backwards compat stuff

module Journey
  class Router
    class RoutingError < ::StandardError
    end

    VERSION = '1.0.0'

    attr_reader :routes, :named_routes

    def initialize options
      @options      = options
      @routes       = []
      @named_routes = {}
    end

    def add_route app, conditions, extras, name
      path = conditions[:path_info]
      route = Route.new(app, path, nil, extras)
      routes << Route.new(app, path, nil, extras)
      named_routes[name] = route if name
    end

    def generate part, name, options, recall = nil, parameterize = nil
      # not sure what part or name is for yet.

      route = named_routes[name] || routes.sort_by { |r| r.score(options) }.last

      route.format options
    end

    def call env
      [200, {}, []]
    end

    def recognize req
      yield(nil, nil, nil)
    end
  end
end
