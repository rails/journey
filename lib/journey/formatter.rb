module Journey
  ###
  # The Formatter class is used for formatting URLs.  For example, parameters
  # passed to +url_for+ in rails will eventually call Formatter#generate
  class Formatter
    attr_reader :routes

    def initialize routes
      @routes = routes
      @cache  = nil
    end

    def generate type, name, options, recall = {}, parameterize = nil
      constraints = recall.merge options

      match_route(name, constraints) do |route|

        keys_to_keep = route.parts.reverse.drop_while { |part|
          !options.key?(part) || (options[part] || recall[part]).nil?
        }

        parameterized_parts = constraints.dup.keep_if do |key, _|
          keys_to_keep.include?(key) || route.required_parts.include?(key)
        end

        if parameterize
          parameterized_parts.each do |k,v|
            parameterized_parts[k] = parameterize.call(k, v)
          end
        end

        parameterized_parts.keep_if { |_,v| v  }

        next unless verify_required_parts!(route, parameterized_parts)

        params = options.dup.delete_if do |key, _|
          parameterized_parts.key?(key) || route.defaults.key?(key)
        end

        return [route.format(parameterized_parts), params]
      end

      raise Router::RoutingError
    end

    def clear
      @cache = nil
    end

    private
    def named_routes
      routes.named_routes
    end

    def match_route name, options
      if named_routes.key? name
        yield named_routes[name]
      else
        #routes = possibles(@cache, options.to_a)
        routes = non_recursive(cache, options.to_a)

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

    def verify_required_parts! route, parts
      tests = route.path.requirements
      route.required_parts.all? { |key|
        if tests.key? key
          /\A#{tests[key]}\Z/ === parts[key]
        else
          parts.fetch(key) { false }
        end
      }
    end

    def build_cache
      kash = {}
      routes.each_with_index do |route, i|
        money = kash
        route.required_defaults.each do |tuple|
          hash = (money[tuple] ||= {})
          money = hash
        end
        (money[:___routes] ||= []) << [i, route]
      end
      kash
    end

    def cache
      @cache ||= build_cache
    end
  end
end
