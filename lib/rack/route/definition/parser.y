class Rack::Route::Definition::Parser

token SLASH LITERAL SYMBOL LPAREN RPAREN DOT

rule
  path
    : SLASH { Nodes::Path.new }
    ;

end

---- header

require 'rack/router/definition/parser_extras'
