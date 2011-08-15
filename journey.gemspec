# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{journey}
  s.version = "1.0.0.20110308150354"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aaron Patterson"]
  s.date = %q{2011-03-08}
  s.description = %q{FIX (describe your package)}
  s.email = ["aaron@tenderlovemaking.com"]
  s.extra_rdoc_files = ["Manifest.txt", "CHANGELOG.rdoc", "README.rdoc"]
  s.files = [".autotest", "CHANGELOG.rdoc", "Manifest.txt", "README.rdoc", "Rakefile", "lib/rack/router.rb", "rack-router.gemspec", "test/test_rack_router.rb", ".gemtest"]
  s.homepage = %q{FIX (url)}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rack-router}
  s.rubygems_version = %q{1.6.0}
  s.summary = %q{FIX (describe your package)}
  s.test_files = ["test/test_rack_router.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe>, [">= 2.9.1"])
    else
      s.add_dependency(%q<hoe>, [">= 2.9.1"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 2.9.1"])
  end
end
