require 'journey/router/utils'
require 'journey/router/strexp'

before = $-w
$-w = false
require 'journey/definition/parser'
$-w = before

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

    def add_route app, conditions, defaults, name = nil
      path = conditions[:path_info]
      route = Route.new(app, path, conditions[:request_method], defaults)
      routes << route
      named_routes[name] = route if name
      route
    end

    def generate part, name, options, recall = nil, parameterize = nil
      route = named_routes[name] || routes.sort_by { |r| r.score(options) }.last

      route.format(options.to_a - route.extras.to_a)
    end

    def call env
      match_data, route = route_for(env)

      return [404, {'X-Cascade' => 'pass'}, ['Not Found']] unless route

      env['action_dispatch.request.path_parameters'] = match_data
      route.app.call(env)
    end

    def recognize req
      match_data, route = route_for req.env
      yield(route, nil, match_data) if route
    end

    private
    def route_for env
      match_data = nil
      route = routes.find do |route|
        next unless route.verb === env['REQUEST_METHOD']
        match_data = route.path =~ env['PATH_INFO']
      end

      return unless route

      [match_data.merge(route.extras), route]
    end
  end
end
