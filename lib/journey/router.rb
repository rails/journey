require 'journey/core-ext/hash'
require 'journey/router/utils'
require 'journey/router/strexp'
require 'journey/routes'

before = $-w
$-w = false
require 'journey/definition/parser'
$-w = before

require 'journey/route'
require 'journey/path/pattern'

module Journey
  class Router
    class RoutingError < ::StandardError
    end

    VERSION = '1.0.0'

    class NullReq # :nodoc:
      attr_reader :env
      def initialize env
        @env = env
      end

      def request_method
        env['REQUEST_METHOD']
      end

      def [](k); env[k]; end
    end

    attr_reader :request_class

    def initialize options
      @options       = options
      @named_routes  = {}
      @params_key    = options[:parameters_key]
      @request_class = options[:request_class] || NullReq
      @cache         = {}
      @routes        = Routes.new
    end

    def named_routes
      @routes.named_routes
    end

    def routes
      @routes
    end

    def add_route app, conditions, defaults, name = nil
      route = routes.add_route app, conditions, defaults, name

      cache = @cache
      route.required_defaults.each do |tuple|
        hash = (cache[tuple] ||= {})
        cache = hash
      end
      (cache[:___routes] ||= []) << [routes.length - 1, route]

      route
    end

    def generate key, name, options, recall = {}, parameterize = nil
      constraints = recall.merge options

      match_route(name, constraints) do |route|
        data = constraints.dup

        keys_to_keep = route.parts.reverse.drop_while { |part|
          !options.key?(part) || (options[part] || recall[part]).nil?
        } | route.required_parts

        (data.keys - keys_to_keep).each do |bad_key|
          data.delete bad_key
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

        return [route.format(parameterized_parts), z]
      end

      raise RoutingError
    end

    def call env
      env['PATH_INFO'] = Utils.normalize_path env['PATH_INFO']

      find_routes(env) do |match, parameters, route|
        script_name, path_info, set_params = env.values_at('SCRIPT_NAME',
                                                           'PATH_INFO',
                                                           @params_key)

        unless route.path.anchored
          env['SCRIPT_NAME'] = script_name.to_s + match.to_s
          env['PATH_INFO']   = match.post_match
        end

        env[@params_key] = (set_params || {}).merge parameters

        status, headers, body = route.app.call(env)

        if 'pass' == headers['X-Cascade']
          env['SCRIPT_NAME'] = script_name
          env['PATH_INFO']   = path_info
          env[@params_key]   = set_params
          next
        end

        return [status, headers, body]
      end

      return [404, {'X-Cascade' => 'pass'}, ['Not Found']]
    end

    def recognize req
      find_routes(req.env) do |match, parameters, route|
        unless route.path.anchored
          req.env['SCRIPT_NAME'] = match.to_s
          req.env['PATH_INFO']   = match.post_match.sub(/^([^\/])/, '/\1')
        end

        yield(route, nil, parameters)
      end
    end

    private
    def non_recursive cache, options
      routes = []
      stack  = [cache]

      while stack.any?
        c = stack.shift
        routes.concat c[:___routes] if c.key? :___routes

        options.each do |pair|
          stack << c[pair] if c.key? pair
        end
      end

      routes
    end

    def possibles cache, options, depth = 0
      cache.fetch(:___routes) { [] } + options.find_all { |pair|
        cache.key? pair
      }.map { |pair|
        possibles(cache[pair], options, depth + 1)
      }.flatten(1)
    end

    def match_route name, options
      if named_routes.key? name
        yield named_routes[name]
      else
        #routes = possibles(@cache, options.to_a)
        routes = non_recursive(@cache, options.to_a)

        hash = routes.group_by { |_, r|
          r.score options
        }

        hash.keys.sort.reverse_each do |score|
          next if score < 0

          hash[score].sort_by { |i,_| i }.each do |_,route|
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
        next if addr && !(r.ip === addr)

        match_data = r.path.match env['PATH_INFO']

        next unless match_data

        match_names = match_data.names.map { |n| n.to_sym }
        info = Hash[match_names.zip(match_data.captures).find_all { |_,y| y }]
        yield(match_data, r.defaults.merge(info), r)
      end
    end

    def verify_required_parts! route, parts
      tests = route.path.requirements
      route.required_parts.all? { |key|
        if tests.key? key
          /\A#{tests[key]}\Z/ === parts[key]
        else
          true
        end
      }
    end
  end
end
