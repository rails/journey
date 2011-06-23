module Journey
  class Route
    attr_reader :app, :path, :verb, :extras, :ip

    ##
    # +path+ is a path constraint.
    # +constraints+ is a hash of constraints to be applied to this route.
    def initialize app, path, constraints, extras = {}
      @app    = app
      @path   = path
      @verb   = constraints[:request_method] || //
      @ip     = constraints[:ip] || //
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

    def format options
      path_options = Hash[options]

      # remove keys the path doesn't care about
      (path_options.keys - parts).each do |key|
        path_options.delete key
      end

      formatter      = Formatter.new(path_options)

      formatted_path = formatter.accept(path.spec)

      formatted_path.empty? ? '/' : formatted_path
    end
  end
end
