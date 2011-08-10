module Journey
  class Route
    attr_reader :app, :path, :verb, :defaults, :ip

    attr_reader :constraints

    ##
    # +path+ is a path constraint.
    # +constraints+ is a hash of constraints to be applied to this route.
    def initialize app, path, constraints, defaults = {}
      @app         = app
      @path        = path
      @verb        = constraints[:request_method] || //
      @ip          = constraints[:ip] || //

      @constraints = constraints.dup
      @constraints.keep_if { |_,v| Regexp === v }
      @defaults = defaults
    end

    def score constraints
      required_keys = path.required_names
      optional_keys = path.optional_names

      constraints.map { |k,v|
        if defaults.key? k
          defaults[k] == v ? 2 : -1
        elsif required_keys.delete(k.to_s)
          1
        elsif optional_keys.delete(k.to_s)
          1
        else
          0
        end
      }.inject(0) { |n,v| n + v } - required_keys.length
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

      def visit_SEGMENT node
        segment = super
        segment == '/' ? '' : segment
      end

      def visit_SYMBOL node
        key = node.to_sym

        if options.key? key
          consumed[key] = options[key]
        else
          ''
        end
      end
      alias :visit_STAR :visit_SYMBOL
    end

    def parts
      path.names.map { |n| n.to_sym }
    end

    def format path_options
      # remove keys the path doesn't care about
      (path_options.keys - parts).each do |key|
        path_options.delete key
      end

      (optional_parts & extras.keys).each do |key|
        path_options.delete key
      end

      formatter      = Formatter.new(path_options)

      formatted_path = formatter.accept(path.spec)

      formatted_path.empty? ? '/' : formatted_path
    end

    def optional_parts
      path.optional_names.map { |n| n.to_sym }
    end

    def required_parts
      path.required_names.map { |n| n.to_sym }
    end
  end
end
