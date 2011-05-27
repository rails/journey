require 'helper'

module Journey
  class TestRouter < MiniTest::Unit::TestCase
    def setup
      @router = Router.new nil
    end

    def test_X_Cascade
      add_routes @router, [ "/messages(.:format)" ]
      resp = @router.call({ 'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/lol' })
      assert_equal ['Not Found'], resp.last
      assert_equal 'pass', resp[1]['X-Cascade']
      assert_equal 404, resp.first
    end

    def test_path_not_found
      add_routes @router, [
        "/messages(.:format)",
        "/messages/new(.:format)",
        "/messages/:id/edit(.:format)",
        "/messages/:id(.:format)"
      ]
      env = rails_env 'PATH_INFO' => '/messages/1.1.1'
      yielded = false

      @router.recognize(env) do |*whatever|
        yielded = false
      end
      refute yielded
    end

    def add_routes router, paths
      paths.each do |path|
        path  = Path::Pattern.new path
        router.add_route nil, {:path_info => path}, {}, {}
      end
    end

    def test_generate_id
      path  = Path::Pattern.new '/:controller(/:action)'
      @router.add_route nil, {:path_info => path}, {}, {}

      path, params = @router.generate(
        :path_info, nil, {:id=>1, :controller=>"tasks", :action=>"show"}, {})
      assert_equal '/tasks/show', path
      assert_equal({:id => 1}, params)
    end

    def test_generate_escapes
      path  = Path::Pattern.new '/:controller(/:action)'
      @router.add_route nil, {:path_info => path}, {}, {}

      path, _ = @router.generate(:path_info,
        nil, { :controller        => "tasks",
               :action            => "show me",
      }, {})
      assert_equal '/tasks/show%20me', path
    end

    def test_generate_extra_params
      path  = Path::Pattern.new '/:controller(/:action)'
      @router.add_route nil, {:path_info => path}, {}, {}

      path, params = @router.generate(:path_info,
        nil, { :id                => 1,
               :controller        => "tasks",
               :action            => "show",
               :relative_url_root => nil
      }, {})
      assert_equal '/tasks/show', path
      assert_equal({:id => 1, :relative_url_root => nil}, params)
    end

    def test_generate_with_name
      path  = Path::Pattern.new '/:controller(/:action)'
      @router.add_route nil, {:path_info => path}, {}, {}

      path, params = @router.generate(:path_info,
        "tasks",
        {:controller=>"tasks"},
        {:controller=>"tasks", :action=>"index"})
      assert_equal '/tasks', path
      assert_equal({}, params)
    end

    def test_extras_are_removed_when_formatting
      path  = Path::Pattern.new "/page/:id(/:action)(.:format)"
      @router.add_route nil, { :path_info => path }, {
        :controller => 'paths',
        :action => 'show'
      }, {}
      path = @router.generate(nil, nil, {
        :controller =>"pages",
        :id         =>20,
        :action     =>"show"
      })
      assert_equal '/page/20', path.first
    end

    {
      '/content'            => { :controller => 'content' },
      '/content/list'       => { :controller => 'content', :action => 'list' },
      '/content/show/10'    => { :controller => 'content', :action => 'show', :id => "10" },
    }.each do |request_path, expected|
      define_method("test_recognize_#{expected.keys.map(&:to_s).join('_')}") do
        path  = Path::Pattern.new "/:controller(/:action(/:id))"
        app   = Object.new
        route = @router.add_route(app, { :path_info => path }, {}, {})

        env = rails_env 'PATH_INFO' => request_path
        called   = false

        @router.recognize(env) do |r, _, params|
          assert_equal route, r
          assert_equal(expected, params)
          called = true
        end

        assert called
      end
    end

    def test_namespaced_controller
      strexp = Router::Strexp.new(
        "/:controller(/:action(/:id))",
        { :controller => /.+/ },
        ["/", ".", "?"]
      )
      path  = Path::Pattern.new strexp
      app   = Object.new
      route = @router.add_route(app, { :path_info => path }, {}, {})

      env = rails_env 'PATH_INFO' => '/admin/users/show/10'
      called   = false
      expected = {
        :controller => 'admin/users',
        :action     => 'show',
        :id         => '10'
      }

      @router.recognize(env) do |r, _, params|
        assert_equal route, r
        assert_equal(expected, params)
        called = true
      end
      assert called
    end

    def test_recognize_literal
      path   = Path::Pattern.new "/books(/:action(.:format))"
      app    = Object.new
      route  = @router.add_route(app, { :path_info => path }, {:controller => 'books'})

      env    = rails_env 'PATH_INFO' => '/books/list.rss'
      expected = { :controller => 'books', :action => 'list', :format => 'rss' }
      called = false
      @router.recognize(env) do |r, _, params|
        assert_equal route, r
        assert_equal(expected, params)
        called = true
      end

      assert called
    end

    def test_recognize_cares_about_verbs
      path   = Path::Pattern.new "/books(/:action(.:format))"
      app    = Object.new
      conditions = {
        :path_info      => path,
        :request_method => 'GET'
      }
      @router.add_route(app, conditions, {})

      conditions = conditions.dup
      conditions[:request_method] = 'POST'

      post = @router.add_route(app, conditions, {})

      env = rails_env 'PATH_INFO' => '/books/list.rss',
                      "REQUEST_METHOD"    => "POST"

      called = false
      @router.recognize(env) do |r, _, params|
        assert_equal post, r
        called = true
      end

      assert called
    end

    private

    RailsEnv = Struct.new(:env)

    def rails_env env
      RailsEnv.new rack_env env
    end

    def rack_env env
      {
        "rack.version"      => [1, 1],
        "rack.input"        => StringIO.new,
        "rack.errors"       => StringIO.new,
        "rack.multithread"  => true,
        "rack.multiprocess" => true,
        "rack.run_once"     => false,
        "REQUEST_METHOD"    => "GET",
        "SERVER_NAME"       => "example.org",
        "SERVER_PORT"       => "80",
        "QUERY_STRING"      => "",
        "PATH_INFO"         => "/content",
        "rack.url_scheme"   => "http",
        "HTTPS"             => "off",
        "SCRIPT_NAME"       => "",
        "CONTENT_LENGTH"    => "0"
      }.merge env
    end
  end
end
