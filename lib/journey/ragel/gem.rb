require 'fileutils'
require 'date'

module Journey
  class Ragel
    class Gem
      attr_reader :gemname, :rl_source, :klass

      def initialize gemname, klass, rl_source
        @klass     = klass
        @gemname   = gemname
        @rl_source = rl_source
      end

      def write_all
        rakefile
        ragel
        extconf
        gemspec
        monkeypatch
      end

      def monkeypatch
        FileUtils.mkdir "lib"
        File.open("lib/#{gemname}.rb", 'w') do |f|
          f.write <<-eoruby
require '#{gemname}.so'
module Journey
  class Router
    private
    def filter_routes path
      parser = #{klass}::Parser.new
      offsets = parser.parse path

      return [] unless offsets
      offsets.map { |i| routes[i] }
    end
  end
end
          eoruby
        end
      end

      def gemspec
        File.open("#{gemname}.gemspec", 'w') do |f|
          f.write <<-eospec
# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name = "#{gemname}"
  s.version = "#{Time.now.to_i}"
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["#{`whoami`}"]
  s.date = "#{Date.today.to_s}"
  s.description = "Roflscale your router"
  s.email = ["aaron@tenderlovemaking.com"]
  s.extensions = ["ext/#{gemname}/extconf.rb"]
  s.files = [
    "Rakefile",
    "ext/#{gemname}/#{gemname}.c",
    "ext/#{gemname}/#{gemname}.rl",
    "ext/#{gemname}/extconf.rb",
    "lib/#{gemname}.rb",
    "#{gemname}.gemspec",
  ]

  s.homepage = "http://github.com/rails/roflscale"
  s.rdoc_options = ["--main", "Rakefile"]
  s.require_paths = ["lib", "ext"]
  s.rubyforge_project = "roflscale"
  s.rubygems_version = "1.8.11"
  s.summary = "omg!"
  s.test_files = []
end
          eospec
        end
      end

      def rakefile
        File.open('Rakefile', 'w') do |f|
          f.puts <<-eorake
file 'ext/#{gemname}/#{gemname}.c' => 'ext/#{gemname}/#{gemname}.rl' do |t|
  sh "ragel  -o \#{t.name} \#{t.prerequisites.first}"
end

task :package => 'ext/#{gemname}/#{gemname}.c' do
  sh 'gem build #{gemname}.gemspec'
end
          eorake
        end
      end

      def ragel
        FileUtils.mkdir_p "ext/#{gemname}"
        File.open("ext/#{gemname}/#{gemname}.rl", 'w') do |f|
          f.write rl_source
        end
      end

      def extconf
        FileUtils.mkdir_p "ext/#{gemname}"
        File.open("ext/#{gemname}/extconf.rb", 'w') do |f|
          f.write "require 'mkmf'\ncreate_makefile '#{gemname}'"
        end
      end
    end
  end
end
