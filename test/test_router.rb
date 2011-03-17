require 'helper'

module Journey
  class TestRouter < MiniTest::Unit::TestCase
    def setup
      @router = Router.new nil
    end

    def test_generate_id
      path  = Path::Pattern.new '/:controller(/:action)'
      @router.add_route nil, {:path_info => path}, {}, nil

      path, params = @router.generate(
        :path_info, nil, {:id=>1, :controller=>"tasks", :action=>"show"}, {})
      assert_equal '/tasks/show', path
      assert_equal({:id => 1}, params)
    end

    def test_generate_extra_params
      path  = Path::Pattern.new '/:controller(/:action)'
      @router.add_route nil, {:path_info => path}, {}, nil

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
      @router.add_route nil, {:path_info => path}, {}, nil

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
      }, nil
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
        route = @router.add_route(app, { :path_info => path }, {}, nil)

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
