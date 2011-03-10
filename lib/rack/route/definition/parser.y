class Rack::Route::Definition::Parser

token SLASH LITERAL SYMBOL LPAREN RPAREN DOT

rule
  path
    : SLASH segment group { result = Node.new(:PATH, val.last(2)) }
    | SLASH segment { result = Node.new(:PATH, [val[1]]) }
    | SLASH { result = Node.new(:PATH) }
    ;
  segment
    : literal path { result = Node.new(:SEGMENT, val) }
    | literal { result = Node.new(:SEGMENT, val) }
    | symbol { result = Node.new(:SEGMENT, val) }
    ;
  group
    : LPAREN path RPAREN { result = Node.new(:GROUP, val[1]) }
    ;
  symbol
    : SYMBOL { result = Node.new(:SYMBOL, val.first) }
    ;
  literal
    : LITERAL { result = Node.new(:LITERAL, val.first) }
    ;

end

---- header

require 'rack/route/definition/parser_extras'
