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
        assert_equal '/', edges.first.first.to_s
      end

      def test_eclosure
        table = tt '/'
        assert_equal [0], table.eclosure(0)

        table = tt ':a|:b'
        assert_equal 3, table.eclosure(0).length

        table = tt '(:a|:b)'
        assert_equal 5, table.eclosure(0).length
        assert_equal 5, table.eclosure([0]).length
      end

      def test_move_one
        table = tt '/'

        assert_equal [1], table.move(0, '/')
        assert_equal [1], table.move([0], '/')
      end

      def test_move_group
        table  = tt 'a|b'
        states = table.eclosure 0

        assert_equal 1, table.move(states, 'a').length
        assert_equal 1, table.move(states, 'b').length
      end

      def test_move_multi
        table  = tt 'a|a'
        states = table.eclosure 0

        assert_equal 2, table.move(states, 'a').length
        assert_equal 0, table.move(states, 'b').length
      end

      def test_move_regexp
        table  = tt 'a|:a'
        states = table.eclosure 0

        assert_equal 2, table.move(states, 'a').length
        assert_equal 1, table.move(states, /[^\.\/\?]+/).length
        assert_equal 1, table.move(states, 'b').length
      end

      def test_alphabet
        table  = tt 'a|:a'
        assert_equal ['a', /[^\.\/\?]+/], table.alphabet

        table  = tt 'a|a'
        assert_equal ['a'], table.alphabet
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
