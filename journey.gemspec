# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{journey}
  s.version = "1.0.0.rc4.20111228163105"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aaron Patterson"]
  s.date = %q{2011-12-28}
  s.description = %q{Journey is a router.  It routes requests.}
  s.email = ["aaron@tenderlovemaking.com"]
  s.extra_rdoc_files = ["Manifest.txt", "CHANGELOG.rdoc", "README.rdoc"]
  s.files = [".autotest", ".gemtest", ".travis.yml", "CHANGELOG.rdoc", "Gemfile", "Manifest.txt", "README.rdoc", "Rakefile", "journey.gemspec", "lib/journey.rb", "lib/journey/backwards.rb", "lib/journey/core-ext/hash.rb", "lib/journey/formatter.rb", "lib/journey/gtg/builder.rb", "lib/journey/gtg/simulator.rb", "lib/journey/gtg/transition_table.rb", "lib/journey/nfa/builder.rb", "lib/journey/nfa/dot.rb", "lib/journey/nfa/simulator.rb", "lib/journey/nfa/transition_table.rb", "lib/journey/nodes/node.rb", "lib/journey/parser.rb", "lib/journey/parser.y", "lib/journey/parser_extras.rb", "lib/journey/path/pattern.rb", "lib/journey/route.rb", "lib/journey/router.rb", "lib/journey/router/strexp.rb", "lib/journey/router/utils.rb", "lib/journey/routes.rb", "lib/journey/scanner.rb", "lib/journey/visitors.rb", "lib/journey/visualizer/d3.min.js", "lib/journey/visualizer/fsm.css", "lib/journey/visualizer/fsm.js", "lib/journey/visualizer/index.html.erb", "lib/journey/visualizer/reset.css", "test/gtg/test_builder.rb", "test/gtg/test_transition_table.rb", "test/helper.rb", "test/nfa/test_simulator.rb", "test/nfa/test_transition_table.rb", "test/nodes/test_symbol.rb", "test/path/test_pattern.rb", "test/route/definition/test_parser.rb", "test/route/definition/test_scanner.rb", "test/router/test_strexp.rb", "test/router/test_utils.rb", "test/test_route.rb", "test/test_router.rb", "test/test_routes.rb"]
  s.homepage = %q{http://github.com/tenderlove/journey}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{journey}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Journey is a router}
  s.test_files = ["test/gtg/test_builder.rb", "test/gtg/test_transition_table.rb", "test/nfa/test_simulator.rb", "test/nfa/test_transition_table.rb", "test/nodes/test_symbol.rb", "test/path/test_pattern.rb", "test/route/definition/test_parser.rb", "test/route/definition/test_scanner.rb", "test/router/test_strexp.rb", "test/router/test_utils.rb", "test/test_route.rb", "test/test_router.rb", "test/test_routes.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<minitest>, ["~> 2.3"])
      s.add_development_dependency(%q<racc>, [">= 1.4.6"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.11"])
      s.add_development_dependency(%q<json>, [">= 0"])
      s.add_development_dependency(%q<hoe>, ["~> 2.12"])
    else
      s.add_dependency(%q<minitest>, ["~> 2.3"])
      s.add_dependency(%q<racc>, [">= 1.4.6"])
      s.add_dependency(%q<rdoc>, ["~> 3.11"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<hoe>, ["~> 2.12"])
    end
  else
    s.add_dependency(%q<minitest>, ["~> 2.3"])
    s.add_dependency(%q<racc>, [">= 1.4.6"])
    s.add_dependency(%q<rdoc>, ["~> 3.11"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<hoe>, ["~> 2.12"])
  end
end
