module Journey
  class Route
    attr_reader :app, :path, :verb, :defaults, :ip

    attr_reader :constraints

    ##
    # +path+ is a path constraint.
    # +constraints+ is a hash of constraints to be applied to this route.
    def initialize app, path, constraints, defaults = {}
      constraints  = constraints.dup
      @app         = app
      @path        = path
      @verb        = constraints[:request_method] || //
      @ip          = constraints.delete(:ip) || //

      @constraints = constraints
      @constraints.keep_if { |_,v| Regexp === v || String === v }
      @defaults    = defaults
      @required_defaults = nil
      @required_parts    = nil
      @parts             = nil
    end

    def required_keys
      path.required_names.map { |x| x.to_sym } + required_defaults.keys
    end

    def score constraints
      required_keys = path.required_names
      supplied_keys = constraints.map { |k,v| v && k.to_s }.compact

      return -1 unless (required_keys - supplied_keys).empty?

      score = (supplied_keys & path.names).length
      score + (required_defaults.length * 2)
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
      @parts ||= path.names.map { |n| n.to_sym }
    end

    def format path_options
      (defaults.keys - required_parts).each do |key|
        path_options.delete key if defaults[key].to_s == path_options[key].to_s
      end

      formatter      = Formatter.new(path_options)

      formatted_path = formatter.accept(path.spec)

      formatted_path.empty? ? '/' : formatted_path
    end

    def optional_parts
      path.optional_names.map { |n| n.to_sym }
    end

    def required_parts
      @required_parts ||= path.required_names.map { |n| n.to_sym }
    end

    def required_defaults
      @required_defaults ||= begin
        matches = parts
        @defaults.dup.delete_if { |k,_| matches.include? k }
      end
    end
  end
end
