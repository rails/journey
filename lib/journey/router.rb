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

    class NullReq # :nodoc:
      def self.new env; env; end
    end

    attr_reader :routes, :named_routes, :request_class

    def initialize options
      @options       = options
      @routes        = []
      @named_routes  = {}
      @params_key    = options[:parameters_key]
      @request_class = options[:request_class] || NullReq
    end

    def add_route app, conditions, defaults, name = nil
      path = conditions[:path_info]
      route = Route.new(app, path, conditions, defaults)
      routes << route
      named_routes[name] = route if name
      route
    end

    def generate key, name, options, recall = {}, parameterize = nil
      constraints = recall.merge(options)

      match_route(name, constraints) do |route|
        data = recall.merge options

        keys_to_keep = route.parts.reverse.drop_while { |part|
          !options.key?(part)
        } | route.required_parts

        (data.keys - keys_to_keep).each do |key|
          data.delete key
        end

        parameterized_parts = data.dup

        if parameterize
          parameterized_parts.each do |k,v|
            parameterized_parts[k] = parameterize[:parameterize].call(k, v)
          end
        end

        parameterized_parts.keep_if { |_,v| v  }

        next unless verify_required_parts!(route, parameterized_parts)

        z = Hash[options.to_a - data.to_a - route.defaults.to_a]
        z.delete :controller
        z.delete :action

        return [route.format(parameterized_parts), z]
      end

      raise RoutingError
    end

    def call env
      find_routes(env) do |match, parameters, route|
        unless match.post_match.empty?
          env['SCRIPT_NAME'] = match.to_s
          env['PATH_INFO']   = match.post_match.sub(/^([^\/])/, '/\1')
        end

        env[@params_key] = parameters

        status, headers, body = route.app.call(env)

        next if headers.key?('X-Cascade') && headers['X-Cascade'] == 'pass'

        return [status, headers, body]
      end

      return [404, {'X-Cascade' => 'pass'}, ['Not Found']]
    end

    def recognize req
      find_routes(req.env) do |match, parameters, route|
        unless match.post_match.empty?
          req.env['SCRIPT_NAME'] = match.to_s
          req.env['PATH_INFO']   = match.post_match.sub(/^([^\/])/, '/\1')
        end

        yield(route, nil, parameters)
      end
    end

    private
    def match_route name, options
      if named_routes.key? name
        yield named_routes[name]
      else
        hash = routes.group_by { |r|
          options.delete_if { |k,v|
            v.nil? && !r.defaults.key?(k)
          }
          r.score options
        }

        hash.keys.sort.reverse_each do |score|
          next if score < 0

          hash[score].each do |route|
            yield route
          end
        end
      end
    end

    def find_routes env
      addr       = env['REMOTE_ADDR']
      req        = request_class.new env

      routes.each do |r|
        next unless r.constraints.all? { |k,v|
          v === req.send(k)
        }

        next unless r.verb === env['REQUEST_METHOD']
        next if addr && !r.ip === addr

        match_data = r.path.match env['PATH_INFO']

        next unless match_data

        match_names = match_data.names.map { |n| n.to_sym }
        info = Hash[match_names.zip(match_data.captures).find_all { |_,y| y }]
        yield(match_data, r.defaults.merge(info), r)
      end
    end

    def verify_required_parts! route, parts
      tests = route.path.requirements
      (tests.keys & route.required_parts).all? { |key|
        /\A#{tests[key]}\Z/ === parts[key]
      }
    end
  end
end
