require 'helper'
require 'erb'

module Journey
  class TestRagel < MiniTest::Unit::TestCase
    def test_rl_source
      parser = Journey::Parser.new

      asts = %w{
        /users(.:format)
        /users/new(.:format)
        /users/:id/edit(.:format)
        /users/:id(.:format)
      }.map { |pattern| parser.parse pattern }


      ragel = Journey::Ragel.new "RagelFun", asts
      assert ragel.source
    end

    def test_ragel
      parser = Journey::Parser.new

      asts = %w{
        /users(.:format)
        /users/new(.:format)
        /users/:id/edit(.:format)
        /users/:id(.:format)
      }.map { |pattern| parser.parse pattern }


      ragel = Journey::Ragel.new 'my_machine', asts
      machine = ragel.machine
      assert_match 'r_0 | r_1 | r_2', machine
      assert_match 'my_machine', machine
    end

    def test_visitor
      viz    = Journey::Visitors::Ragel.new
      parser = Journey::Parser.new

      ast = parser.parse '/users/:id/edit(.:format)'
      rule = viz.accept ast

      assert_equal '"/" . "users" . "/" . /[^/]/+ . "/" . "edit" . ("." . /[^/]/+)?', rule
    end
  end
end
