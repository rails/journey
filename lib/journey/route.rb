module Journey
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
      possible_keys = path.names

      constraints.map { |k,v|
        if extras.key? k
          extras[k] == v ? 2 : -1
        elsif possible_keys.include?(k.to_s) && v
          1
        else
          0
        end
      }.inject(0) { |n,v| n + v }
    end

    class Formatter < ::Journey::Definition::Node::String
      attr_reader :options, :consumed

      def initialize options
        @options  = options
        @consumed = {}
      end

      def visit_GROUP node
        if consumed == options
          ''
        else
          node.children.map { |x| accept x }.join
        end
      end

      def visit_SYMBOL node
        key = node.to_sym

        if options.key? key
          consumed[key] = options[key]
        else
          ''
        end
      end
    end

    def format options
      path_options = Hash[options.reject { |k,v|
        v.respond_to?(:to_param) && v.to_param.nil?
      }]

      possible_keys = path.names.map { |n| n.to_sym }

      # remove keys the path doesn't care about
      (path_options.keys - possible_keys).each do |key|
        path_options.delete key
      end

      formatter      = Formatter.new(path_options)
      formatted_path = formatter.accept(path.spec)

      options = Hash[options.to_a - formatter.consumed.to_a]
      options.delete(:controller)
      options.delete(:action)

      [formatted_path, options]
    end
  end
end
