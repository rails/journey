require 'rack/router/utils'
require 'rack/router/strexp'
require 'rack/router/route'
require 'rack/router/definition/scanner'
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
      #p [part, name, options, recall, parameterize]
      #p @routes
      # not sure what part or name is for yet.

      route = routes.find { |r| r.connects_to?(options) }

      options = options.dup
      path = [:controller, :action].map { |url_part|
        options.delete url_part
      }.compact.join '/'
      ["/#{path}", options]
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
