require 'helper'

module Journey
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

    def test_score
      path = Path::Pattern.new "/page/:id(/:action)(.:format)"
      specific = Route.new nil, path, nil, {:controller=>"pages", :action=>"show"}

      path = Path::Pattern.new "/:controller(/:action(/:id))(.:format)"
      generic = Route.new nil, path, {}

      knowledge = {:id=>20, :controller=>"pages", :action=>"show"}

      routes = [specific, generic]

      refute_equal specific.score(knowledge), generic.score(knowledge)

      found = routes.sort_by { |r| r.score(knowledge) }.last

      assert_equal specific, found
    end
  end
end
