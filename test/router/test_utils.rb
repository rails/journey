require 'helper'

module Journey
  class Router
    class TestUtils < MiniTest::Unit::TestCase
      def test_cgi_escape
        assert_equal "a%2Fb", Utils.escape_uri("a/b")
      end
    end
  end
end
