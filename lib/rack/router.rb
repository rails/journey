require 'rack/router/utils'
require 'rack/router/strexp'
require 'rack/router/route'
require 'rack/route/definition/parser'
require 'rack/router/path/pattern'

module Rack
  class Router
    class RoutingError < ::StandardError
    end

    VERSION = '1.0.0'

    attr_reader :routes

    def initialize options
      @options = options
      @routes  = []
    end

    def add_route app, conditions, extras, name
      path = conditions[:path_info]
      routes << Route.new(app, path, nil, extras)
    end

    def generate part, name, options, recall = nil, parameterize = nil
      # not sure what part or name is for yet.

      route = routes.sort_by { |r| r.score(options) }.last

      route.format options
    end

    def call env
      [200, {}, []]
    end

    def recognize req
      yield(nil, nil, nil)
    end

    RegexpWithNamedGroups = Path::Pattern
  end

  Mount = Router
  Mount::RouteSet = Router
end
