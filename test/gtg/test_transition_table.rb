require 'helper'

module Journey
  module GTG
    class TestGeneralizedTable < MiniTest::Unit::TestCase
      def test_reduction_states
        table = tt ['/foo', '/bar']
        t2    = table.generalized_table

        assert_operator table.states.length, :>, t2.states.length
      end

      def test_simulate_gt
        sim = simulator_for ['/foo', '/bar']
        assert_match sim, '/foo'
      end

      def test_simulate_gt_regexp
        sim = simulator_for [':foo']
        assert_match sim, 'foo'
      end

      def test_simulate_gt_regexp_mix
        sim = simulator_for ['/get', '/:method/foo']
        assert_match sim, '/get'
        assert_match sim, '/get/foo'
      end

      def test_simulate_optional
        sim = simulator_for ['/foo(/bar)']
        assert_match sim, '/foo'
        assert_match sim, '/foo/bar'
        refute_match sim, '/foo/'
      end

      def test_match_data
        path_asts = asts %w{ /get /:method/foo }
        paths     = path_asts.dup

        builder = NFA::Builder.new path_asts.inject(path_asts.shift) { |l,r|
          Nodes::Or.new l, r
        }
        sim = NFA::Simulator.new builder.transition_table.generalized_table

        match = sim.match '/get'
        assert_equal [paths.first], match.memos

        match = sim.match '/get/foo'
        assert_equal [paths.last], match.memos
      end

      def test_match_data_ambiguous
        path_asts = asts %w{
          /articles(.:format)
          /articles/new(.:format)
          /articles/:id/edit(.:format)
          /articles/:id(.:format)
        }

        paths = path_asts.dup
        ast   = path_asts.inject(path_asts.shift) { |l,r| Nodes::Or.new l, r }

        builder = NFA::Builder.new ast
        sim     = NFA::Simulator.new builder.transition_table.generalized_table

        match = sim.match '/articles/new'
        assert_equal [paths[1], paths[3]], match.memos
      end

      private
      def asts paths
        parser  = Journey::Parser.new
        paths.map { |x|
          ast = parser.parse x
          ast.each { |n| n.memo = ast}
          ast
        }
      end

      def tt paths
        x = asts paths
        builder = NFA::Builder.new x.inject(x.shift) { |l,r|
          Nodes::Or.new l, r
        }
        builder.transition_table
      end

      def simulator_for paths
        NFA::Simulator.new tt(paths).generalized_table
      end
    end
  end
end
