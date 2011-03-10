require 'helper'

module Rack
  class Router
    class TestRoute < MiniTest::Unit::TestCase
      def test_initialize
        app   = Object.new
        path  = Object.new
        verb  = Object.new
        route = Route.new(app, path, verb)

        assert_equal app, route.app
        assert_equal path, route.path
        assert_equal verb, route.verb
      end

      def test_connects_all_match
        route = Route.new(nil, nil, nil,
                          { :controller => 'foo', :action => 'bar' })

        assert !route.connects_to?({ :controller => 'foo' })
        assert route.connects_to?({ :controller => 'foo', :action => 'bar' })
        assert route.connects_to?({
          :controller => 'foo',
          :action     => 'bar',
          :id         => 10
        })
      end
    end
  end
end
