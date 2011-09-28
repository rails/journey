require 'helper'

module Journey
  module GTG
    class TestBuilder < MiniTest::Unit::TestCase
      def test_following_states_multi
        table  = tt ['a|a']
        assert_equal 1, table.move(0, 'a').length
      end

      def test_following_states_multi_regexp
        table  = tt [':a|b']
        assert_equal 1, table.move(0, 'fooo').length
        assert_equal 2, table.move(0, 'b').length
      end

      def test_multi_path
        table  = tt ['/:a/d', '/b/c']

        [
          [1, '/'],
          [2, 'b'],
          [2, '/'],
          [1, 'c'],
        ].inject(0) { |state, (exp, sym)|
          new = table.move(state, sym)
          assert_equal exp, new.length
          new
        }
      end

      private
      def tt strings
        parser = Journey::Parser.new
        asts   = strings.map { |string| parser.parse string }
        ast    = asts.inject(asts.shift) { |l,r| Nodes::Or.new(l,r) }
        builder = Builder.new ast
        builder.transition_table
      end
    end
  end
end
