require 'helper'

module Journey
  class TestRoutes < MiniTest::Unit::TestCase
    def test_clear
      routes = Routes.new
      exp    = Router::Strexp.new '/foo(/:id)', {}, ['/.?']
      path   = Path::Pattern.new exp
      requirements = { :hello => /world/ }

      routes.add_route nil, path, requirements, {:id => nil}, {}
      assert_equal 1, routes.length

      routes.clear
      assert_equal 0, routes.length
    end
  end
end
