class Journey::Parser

token SLASH LITERAL SYMBOL LPAREN RPAREN DOT STAR

rule
  expressions
    : expression              { result = val.first }
    | expression expressions  { result = Cat.new(val) }
    ;
  expression
    : terminal
    | group
    | star
    ;
  group
    : LPAREN expressions RPAREN { result = Group.new([val[1]]) }
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

require 'journey/parser_extras'
