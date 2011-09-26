require 'helper'

module Journey
  module NFA
    class TestSimulator < MiniTest::Unit::TestCase
      def test_simulate_simple
        sim = simulator_for ['/foo']
        assert_match sim, '/foo'
      end

      def test_simulate_simple_no_match
        sim = simulator_for ['/foo']
        refute_match sim, 'foo'
      end

      def test_simulate_simple_no_match_too_long
        sim = simulator_for ['/foo']
        refute_match sim, '/foo/bar'
      end

      def test_simulate_simple_no_match_wrong_string
        sim = simulator_for ['/foo']
        refute_match sim, '/bar'
      end

      def test_simulate_regex
        sim = simulator_for ['/:foo/bar']
        assert_match sim, '/bar/bar'
        assert_match sim, '/foo/bar'
      end

      def test_simulate_or
        sim = simulator_for ['/foo', '/bar']
        assert_match sim, '/bar'
        assert_match sim, '/foo'
        refute_match sim, '/baz'
      end

      def test_simulate_optional
        sim = simulator_for ['/foo(/bar)']
        assert_match sim, '/foo'
        assert_match sim, '/foo/bar'
        refute_match sim, '/foo/'
      end

      def simulator_for paths
        parser  = Journey::Parser.new
        asts    = paths.map { |x| parser.parse x }
        builder = Builder.new asts.inject(asts.shift) { |l,r|
          Nodes::Or.new l, r
        }
        Simulator.new builder.transition_table
      end
    end
  end
end
