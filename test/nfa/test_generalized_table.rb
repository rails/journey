require 'helper'

module Journey
  module NFA
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

      private
      def tt paths
        parser  = Journey::Parser.new
        asts    = paths.map { |x| parser.parse x }
        builder = Builder.new asts.inject(asts.shift) { |l,r|
          Nodes::Or.new l, r
        }
        builder.transition_table
      end

      def simulator_for paths
        Simulator.new tt(paths).generalized_table
      end
    end
  end
end
