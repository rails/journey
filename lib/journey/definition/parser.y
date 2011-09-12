class Journey::Definition::Parser

token SLASH LITERAL SYMBOL LPAREN RPAREN DOT STAR

rule
  paths
    : path               { result = val.first }
    | path paths         { result = Node.new(:CAT, val) }
    ;
  path
    : terminal
    | group
    | star
    ;
  group
    : LPAREN paths RPAREN { result = Node.new(:GROUP, [val[1]]) }
    ;
  star
    : STAR literal       { result = Node.new(:STAR, [Node.new(:SYMBOL, val.last.children)]) }
    ;
  terminal
    : symbol
    | literal
    | slash
    ;
  slash
    : SLASH              { result = Node.new(:SLASH, '/') }
    ;
  symbol
    : SYMBOL             { result = Node.new(:SYMBOL, val.first) }
    ;
  literal
    : LITERAL            { result = Node.new(:LITERAL, val.first) }
    ;

end

---- header

require 'journey/definition/parser_extras'
