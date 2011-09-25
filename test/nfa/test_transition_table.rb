require 'helper'

module Journey
  module NFA
    class TestTransitionTable < MiniTest::Unit::TestCase
      def setup
        @parser = Journey::Parser.new
      end

      def test_one_edge
        table = tt '/'
        edges = table.edges(0)

        assert_equal 1, edges.length
        assert_equal '/', edges.first.first
      end

      def test_eclosure
        table = tt '/'
        assert_equal [], table.eclosure(0)

        table = tt ':a|:b'
        assert_equal 2, table.eclosure(0).length

        table = tt '(:a|:b)'
        assert_equal 4, table.eclosure(0).length
        assert_equal 4, table.eclosure([0]).length
      end

      private
      def tt string
        ast     = @parser.parse string
        builder = Builder.new ast
        builder.transition_table
      end
    end
  end
end
