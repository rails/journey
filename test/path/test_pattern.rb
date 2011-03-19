require 'helper'

module Journey
  module Path
    class TestPattern < MiniTest::Unit::TestCase
      {
        '/:controller(/:action)'       => %r{\A/(.+?)(?:/([^/.?]+))?\Z},
        '/:controller/foo'             => %r{\A/(.+?)/foo\Z},
        '/:controller/:action'         => %r{\A/(.+?)/([^/.?]+)\Z},
        '/:controller'                 => %r{\A/(.+?)\Z},
        '/:controller(/:action(/:id))' => %r{\A/(.+?)(?:/([^/.?]+)(?:/([^/.?]+))?)?\Z},
        '/:controller/:action.xml'     => %r{\A/(.+?)/([^/.?]+)\.xml\Z},
        '/:controller.:format'         => %r{\A/(.+?)\.([^/.?]+)\Z},
        '/:controller(.:format)'       => %r{\A/(.+?)(?:\.([^/.?]+))?\Z},
        '/:controller/*foo'            => %r{\A/(.+?)/(.+)\Z},
        '/:controller/*foo/bar'        => %r{\A/(.+?)/(.+)/bar\Z},
      }.each do |path, expected|
        define_method(:"test_to_regexp_#{path}") do
          strexp = Router::Strexp.new(
            path,
            { :controller => /.+/ },
            ["/", ".", "?"]
          )
          path = Pattern.new strexp
          re = path.to_regexp
          assert_equal(expected, re)
        end
      end

      def test_to_regexp_with_strexp
        strexp = Router::Strexp.new('/:controller', { }, ["/", ".", "?"])
        path = Pattern.new strexp
        re = path.to_regexp
        x = %r{\A/([^/.?]+)\Z}

        assert_equal(x.source, re.source)
        assert_equal(x, re)
      end

      def test_match_controller
        path = Pattern.new '/:controller(/:action(/:id(.:format)))'
        uri = '/content'

        match = path =~ uri
        assert_equal({:controller => 'content'}, match)
      end

      def test_match_controller_action
        path = Pattern.new '/:controller(/:action(/:id(.:format)))'
        uri = '/content/list'

        match = path =~ uri
        assert_equal({:controller => 'content', :action => 'list'}, match)
      end

      def test_match_controller_action_id
        path = Pattern.new '/:controller(/:action(/:id(.:format)))'
        uri = '/content/list/10'

        match = path =~ uri
        assert_equal({:controller => 'content', :action => 'list', :id => '10'}, match)
      end

      def test_match_literal
        path = Path::Pattern.new "/books(/:action(.:format))"

        uri = '/books'
        match = path =~ uri
        assert_equal({}, match)
      end

      def test_match_literal_with_action
        path = Path::Pattern.new "/books(/:action(.:format))"

        uri = '/books/list'
        match = path =~ uri
        assert_equal({:action => 'list'}, match)
      end

      def test_match_literal_with_action_and_format
        path = Path::Pattern.new "/books(/:action(.:format))"

        uri = '/books/list.rss'
        match = path =~ uri
        assert_equal({:action => 'list', :format => 'rss'}, match)
      end
    end
  end
end
