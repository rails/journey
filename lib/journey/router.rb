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
      route = Route.new(app, path, conditions, defaults)
      routes << route
      named_routes[name] = route if name
      route
    end

    def generate part, name, options, recall = {}, parameterize = nil
      route = named_routes[name] || match_route(options)

      provided_parts = route.parts.reverse.drop_while { |part|
        !options.key?(part)
      }.reverse

      route_values = provided_parts.map { |part|
        [part, options[part] || recall[part]]
      } - route.extras.to_a

      z = Hash[options.to_a - route_values]
      z.delete :controller
      z.delete :action

      return [route.format(route_values), z]

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
    def match_route options
      routes.sort_by { |r| r.score options }.last
    end

    def route_for env
      match_data = nil
      addr       = env['REMOTE_ADDR']

      route = routes.find do |r|
        next unless r.verb === env['REQUEST_METHOD']
        next if addr && !r.ip === addr
        match_data = r.path =~ env['PATH_INFO']
      end

      return unless route

      [match_data.merge(route.extras), route]
    end
  end
end
