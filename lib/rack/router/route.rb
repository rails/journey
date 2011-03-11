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

      def score constraints
        constraints.map { |k,v|
          if extras.key? k
            extras[k] == v ? 1 : -1
          else
            0
          end
        }.inject(0) { |n,v| n + v}
      end

      class Formatter < ::Rack::Route::Definition::Node::String
        attr_reader :options, :consumed

        def initialize options
          @options  = options
          @consumed = {}
          @halt     = false
        end

        def accept node
          super unless @halt || consumed == options
        end

        def visit_GROUP node
          node.children.map { |x| accept x }.join
        end

        def visit_SYMBOL node
          key = node.to_sym

          if options.key? key
            consumed[key] = options[key]
          else
            @halt = true
            ''
          end
        end
      end

      def format options
        p options => path.spec.to_s
        path_options = options.dup

        possible_keys = path.spec.find_all { |node|
          node.type == :SYMBOL
        }.map { |n| n.to_sym }

        # remove keys the path doesn't care about
        (path_options.keys - possible_keys).each do |key|
          path_options.delete key
        end

        formatter      = Formatter.new(path_options)
        formatted_path = formatter.accept(path.spec)

        options = Hash[options.to_a - formatter.consumed.to_a]
        options.delete(:controller)

        [formatted_path.chomp('/'), options]
      end
    end
  end
end
