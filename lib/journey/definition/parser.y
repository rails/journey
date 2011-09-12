class Journey::Definition::Parser

token SLASH LITERAL SYMBOL LPAREN RPAREN DOT STAR

rule
  paths
    : path               { result = val.first }
    | path paths  { result = Cat.new(val) }
    ;
  path
    : terminal
    | group
    | star
    ;
  group
    : LPAREN paths RPAREN { result = Group.new([val[1]]) }
    ;
  star
    : STAR literal       { result = Star.new([Symbol.new(val.last.children)]) }
    ;
  terminal
    : symbol
    | literal
    | slash
    | dot
    ;
  slash
    : SLASH              { result = Slash.new('/') }
    ;
  symbol
    : SYMBOL             { result = Symbol.new(val.first) }
    ;
  literal
    : LITERAL            { result = Literal.new(val.first) }
  dot
    : DOT                { result = Dot.new(val.first) }
    ;

end

---- header

require 'journey/definition/parser_extras'
