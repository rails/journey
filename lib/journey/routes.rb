module Journey
  ###
  # The Routing table.  Contains all routes for a system.  Routes can be
  # added to the table by calling Routes#add_route
  class Routes
    include Enumerable

    attr_reader :routes, :named_routes

    def initialize
      @routes       = []
      @named_routes = {}
    end

    def length
      @routes.length
    end

    def each(&block)
      routes.each(&block)
    end

    def clear
      routes.clear
    end

    ###
    # Add a route to the routing table.
    def add_route app, conditions, defaults, name = nil
      path = conditions[:path_info]
      route = Route.new(app, path, conditions, defaults)

      routes << route
      named_routes[name] = route if name
      route
    end
  end
end
