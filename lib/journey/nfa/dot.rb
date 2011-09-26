# encoding: utf-8

module Journey
  module NFA
    module Dot
      def to_dot
        edges = transitions.map { |from, sym, to|
          "#{from} -> #{to} [label=\"#{sym || 'ε'}\"];"
        }

        nodes = states.map { |i| "#{i} [label=\"#{i}\"];" }

        <<-eodot
digraph nfa {
  rankdir=LR;
  size="8,5"
  node [shape = doublecircle];
  #{accepting};
  node [shape = circle];
  #{nodes.join "\n"}
  #{edges.join "\n"}
}
        eodot
      end
    end
  end
end
