# -*- ruby -*-

require 'rubygems'
require 'hoe'

Hoe.plugins.delete :rubyforge
Hoe.plugin :minitest
Hoe.plugin :gemspec # `gem install hoe-gemspec`
Hoe.plugin :git     # `gem install hoe-git`

Hoe.spec 'rack-router' do
  developer('Aaron Patterson', 'aaron@tenderlovemaking.com')
  self.readme_file      = 'README.rdoc'
  self.history_file     = 'CHANGELOG.rdoc'
  self.extra_rdoc_files = FileList['*.rdoc']
end

rule '.rb' => '.y' do |t|
  sh "racc -l -o #{t.name} #{t.source}"
end

task :compile => "lib/journey/route/definition/parser.rb"

Rake::Task[:test].prerequisites.unshift "lib/journey/route/definition/parser.rb"

# vim: syntax=ruby
