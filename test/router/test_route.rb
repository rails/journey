require 'helper'

module Journey
  class Router
    class TestRoute < MiniTest::Unit::TestCase
      def test_initialize
        app   = Object.new
        path  = Path::Pattern.new '/:controller(/:action(/:id(.:format)))'
        verb  = Object.new
        route = Route.new(app, path, verb)

        assert_equal app, route.app
        assert_equal path, route.path
        assert_equal verb, route.verb
      end

      def test_connects_all_match
        path  = Path::Pattern.new '/:controller(/:action(/:id(.:format)))'
        route = Route.new(nil, path, nil,
                          { :controller => 'foo', :action => 'bar' })

        assert_equal ['/foo/bar/10', {}], route.format({
          :controller => 'foo',
          :action     => 'bar',
          :id         => 10
        })
      end
    end
  end
end
