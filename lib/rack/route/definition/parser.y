class Rack::Route::Definition::Parser

token SLASH LITERAL SYMBOL LPAREN RPAREN DOT

rule
  path
    : SLASH { result = Nodes::Path.new }
    ;

end

---- header

require 'rack/route/definition/parser_extras'
