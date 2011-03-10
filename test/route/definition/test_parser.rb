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
            "/#{node.children.map { |x| v accept node }.join}"
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
          @parser.parse('/foo')
        end

        def test_segment_symbol
          @parser.parse('/foo/:id')
        end

        def test_segment_group
          @parser.parse('/foo(/:action)')
        end

        def assert_round_trip str
          assert_equal str, @emit.accept(@parser.parse(str))
        end
      end
    end
  end
end
