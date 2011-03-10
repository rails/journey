require 'helper'

module Rack
  module Route
    module Definition
      class TestParser < MiniTest::Unit::TestCase
        class Visitor
          def accept node
            send "visit_#{node.type}", node
          end

          def visit_PATH node
            node.children.map { |x| accept x }.join
          end

          def visit_STAR node
            "*" + node.children
          end

          def visit_DOT node
            "." + node.children.map { |x| accept x }.join
          end

          def visit_SEGMENT node
            "/" + node.children.map { |x| accept x }.join
          end

          def visit_LITERAL node
            node.children
          end

          def visit_SYMBOL node
            node.children
          end

          def visit_GROUP node
            "(#{accept node.children})"
          end
        end

        def setup
          @parser = Definition::Parser.new
          @emit = Visitor.new
        end

        def test_slash
          assert_equal :PATH, @parser.parse('/').type
          assert_round_trip '/'
        end

        def test_segment
          assert_round_trip '/foo'
        end

        def test_segments
          assert_round_trip '/foo/bar'
        end

        def test_segment_symbol
          assert_round_trip '/foo/:id'
        end

        def test_symbol
          assert_round_trip '/:foo'
        end

        def test_group
          assert_round_trip '(/:foo)'
        end

        def test_groups
          assert_round_trip '(/:foo)(/:bar)'
        end

        def test_nested_groups
          assert_round_trip '(/:foo(/:bar))'
        end

        def test_dot_symbol
          assert_round_trip('.:format')
        end

        def test_dot_literal
          assert_round_trip('.xml')
        end

        def test_segment_dot
          assert_round_trip('/foo.:bar')
        end

        def test_segment_group_dot
          assert_round_trip('/foo(.:bar)')
        end

        def test_segment_group
          assert_round_trip('/foo(/:action)')
        end

        def test_segment_groups
          assert_round_trip('/foo(/:action)(/:bar)')
        end

        def test_segment_nested_groups
          assert_round_trip('/foo(/:action(/:bar))')
        end

        def test_group_followed_by_path
          assert_round_trip('/foo(/:action)/:bar')
        end

        def test_star
          assert_round_trip('*foo')
          assert_round_trip('/bar/*foo')
          assert_round_trip('/bar/(*foo)')
        end

        def assert_round_trip str
          assert_equal str, @emit.accept(@parser.parse(str))
        end
      end
    end
  end
end
