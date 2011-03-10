class Rack::Route::Definition::Parser

token SLASH LITERAL SYMBOL LPAREN RPAREN DOT

rule
  path
    : segment path { result = Node.new(:PATH, val) }
    | segment groups { result = Node.new(:PATH, val.flatten) }
    | segment { result = Node.new(:PATH, val) }
    | groups { result = Node.new(:PATH, val.flatten) }
    ;
  segment
    : SLASH literal { result = Node.new(:SEGMENT, [val.last]) }
    | SLASH symbol { result = Node.new(:SEGMENT, [val.last]) }
    | SLASH { result = Node.new(:SEGMENT, []) }
    ;
  groups
    : groups group { result = val.flatten }
    | group
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
