require 'helper'

module Rack
  module Route
    module Definition
      class TestParser < MiniTest::Unit::TestCase
        def setup
          @parser = Definition::Parser.new
        end

        def test_slash
          assert_kind_of Nodes::Path, @parser.parse('/')
        end
      end
    end
  end
end
