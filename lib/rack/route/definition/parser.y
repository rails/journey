class Rack::Route::Definition::Parser

token SLASH LITERAL SYMBOL LPAREN RPAREN DOT STAR

rule
  path
    : segment path       { result = Node.new(:PATH, val.flatten) }
    | segment            { result = Node.new(:PATH, val.flatten) }
    | groups             { result = Node.new(:PATH, val.flatten) }
    | dot                { result = Node.new(:PATH, val.flatten) }
    | star               { result = Node.new(:PATH, val.flatten) }
    ;
  segment
    : SLASH literal      { result = Node.new(:SEGMENT, [val.last]) }
    | SLASH symbol       { result = Node.new(:SEGMENT, [val.last]) }
    | SLASH              { result = Node.new(:SEGMENT, []) }
    ;
  dot
    : DOT symbol         { result = Node.new(:DOT, [val.last]) }
    | DOT literal        { result = Node.new(:DOT, [val.last]) }
    ;
  groups
    : group groups       { result = val.flatten }
    | group
    ;
  group
    : LPAREN path RPAREN { result = Node.new(:GROUP, val[1]) }
    ;
  symbol
    : SYMBOL             { result = Node.new(:SYMBOL, val.first) }
    ;
  literal
    : LITERAL            { result = Node.new(:LITERAL, val.first) }
  star
    : STAR LITERAL       { result = Node.new(:STAR, val.last) }
    ;

end

---- header

require 'rack/route/definition/parser_extras'
