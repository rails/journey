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

      {
        '/:controller(/:action)'       => %w{ controller action },
        '/:controller/foo'             => %w{ controller },
        '/:controller/:action'         => %w{ controller action },
        '/:controller'                 => %w{ controller },
        '/:controller(/:action(/:id))' => %w{ controller action id },
        '/:controller/:action.xml'     => %w{ controller action },
        '/:controller.:format'         => %w{ controller format },
        '/:controller(.:format)'       => %w{ controller format },
        '/:controller/*foo'            => %w{ controller foo },
        '/:controller/*foo/bar'        => %w{ controller foo },
      }.each do |path, expected|
        define_method(:"test_names_#{path}") do
          strexp = Router::Strexp.new(
            path,
            { :controller => /.+/ },
            ["/", ".", "?"]
          )
          path = Pattern.new strexp
          assert_equal(expected, path.names)
        end
      end

      def test_to_regexp_with_group
        strexp = Router::Strexp.new(
          '/page/:name',
          { :name => /(tender|love)/ },
          ["/", ".", "?"]
        )
        path = Pattern.new strexp
        assert_match('/page/tender', path.to_regexp)
        assert_match('/page/love', path.to_regexp)
        refute_match('/page/loving', path.to_regexp)
      end

      def test_match_data_with_group
        strexp = Router::Strexp.new(
          '/page/:name',
          { :name => /(tender|love)/ },
          ["/", ".", "?"]
        )
        path = Pattern.new strexp
        match = path.to_regexp.match '/page/tender'
        assert_equal 2, match.length
      end

      def test_to_regexp_with_strexp
        strexp = Router::Strexp.new('/:controller', { }, ["/", ".", "?"])
        path = Pattern.new strexp
        re = path.to_regexp
        x = %r{\A/([^/.?]+)\Z}

        assert_equal(x.source, re.source)
        assert_equal(x, re)
      end

      def test_to_regexp_defaults
        path = Pattern.new '/:controller(/:action(/:id))'
        expected = %r{\A/([^/.?]+)(?:/([^/.?]+)(?:/([^/.?]+))?)?\Z}
        assert_equal expected, path.to_regexp
      end

      def test_failed_match
        path = Pattern.new '/:controller(/:action(/:id(.:format)))'
        uri = 'content'

        refute path =~ uri
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
