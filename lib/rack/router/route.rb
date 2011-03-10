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

      def score constraints
        constraints.map { |k,v|
          if extras.key? k
            extras[k] == v ? 1 : -1
          else
            0
          end
        }.inject(0) { |n,v| n + v}
      end

      def format options
        options = options.dup

        p path.spec.to_s => options
        p path.spec
        list = path.spec.map { |node|
          p node.type
          case node.type
          when :SEGMENT then '/'
          when :LITERAL then node.children
          when :SYMBOL then options.delete(node.children.tr(':', '').to_sym)
          else '' end
        }

        p list
        formatted_path = list.join

        options.delete(:controller)

        p :zomg => formatted_path

        [formatted_path.chomp('/'), options]
      end
    end
  end
end
