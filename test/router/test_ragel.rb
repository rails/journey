require 'helper'
require 'erb'
require 'tempfile'
require 'fileutils'

module Journey
  class TestRagel < MiniTest::Unit::TestCase
    def test_gem
      parser = Journey::Parser.new

      asts = %w{
        /users(.:format)
        /users/new(.:format)
        /users/:id/edit(.:format)
        /users/:id(.:format)
      }.map { |pattern| parser.parse pattern }


      ragel = Journey::Ragel.new "RagelFun", asts
      source = ragel.source

      gemdir = File.join Dir.tmpdir, 'roflscale'

      FileUtils.rm_rf gemdir
      FileUtils.mkdir_p gemdir

      Dir.chdir gemdir do
        gem = Journey::Ragel::Gem.new 'roflscale', 'RagelFun', source
        gem.write_all

        assert_equal source, File.read('ext/roflscale/roflscale.rl')
        assert File.exists? 'Rakefile'
        assert File.exists? 'ext/roflscale/extconf.rb'
        assert File.exists? 'lib/roflscale.rb'
        assert File.exists? 'roflscale.gemspec'
      end
    end

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
