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
  end
end
