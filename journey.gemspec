# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "journey"
  s.version = "1.0.0.20110902101342"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aaron Patterson"]
  s.date = "2011-09-02"
  s.description = "Journey is a router.  It routes requests."
  s.email = ["aaron@tenderlovemaking.com"]
  s.extra_rdoc_files = ["Manifest.txt", "CHANGELOG.rdoc", "README.rdoc"]
  s.files = [".autotest", "CHANGELOG.rdoc", "Gemfile", "Manifest.txt", "README.rdoc", "Rakefile", "journey.gemspec", "lib/journey/backwards.rb", "lib/journey/core-ext/hash.rb", "lib/journey/definition/node.rb", "lib/journey/definition/parser.rb", "lib/journey/definition/parser.y", "lib/journey/definition/parser_extras.rb", "lib/journey/definition/scanner.rb", "lib/journey/path/pattern.rb", "lib/journey/route.rb", "lib/journey/router.rb", "lib/journey/router/strexp.rb", "lib/journey/router/utils.rb", "test/helper.rb", "test/path/test_pattern.rb", "test/route/definition/test_parser.rb", "test/route/definition/test_scanner.rb", "test/router/test_strexp.rb", "test/router/test_utils.rb", "test/test_route.rb", "test/test_router.rb", ".gemtest"]
  s.homepage = "http://github.com/tenderlove/journey"
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "journey"
  s.rubygems_version = "1.8.10"
  s.summary = "Journey is a router"
  s.test_files = ["test/path/test_pattern.rb", "test/route/definition/test_parser.rb", "test/route/definition/test_scanner.rb", "test/router/test_strexp.rb", "test/router/test_utils.rb", "test/test_route.rb", "test/test_router.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<minitest>, ["~> 2.5"])
      s.add_development_dependency(%q<hoe>, ["~> 2.10"])
    else
      s.add_dependency(%q<minitest>, ["~> 2.5"])
      s.add_dependency(%q<hoe>, ["~> 2.10"])
    end
  else
    s.add_dependency(%q<minitest>, ["~> 2.5"])
    s.add_dependency(%q<hoe>, ["~> 2.10"])
  end
end
