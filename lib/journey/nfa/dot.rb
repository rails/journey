# encoding: utf-8

module Journey
  module NFA
    module Dot
      def to_dot
        edges = transitions.map { |from, sym, to|
          "    #{from} -> #{to} [label=\"#{sym || 'ε'}\"];"
        }

        memo_nodes = memos.values.flatten.map { |n|
          "  #{n.object_id} [label=\"#{n}\", color=1, style=filled, shape=note];"
        }
        memo_edges = memos.map { |k, memos|
          memos.map { |v| "  #{k} -> #{v.object_id} [color=5];" }
        }.flatten

        <<-eodot
digraph nfa {
  rankdir=LR;
  edge [colorscheme=paired7];
  node [colorscheme=paired7];
  subgraph cluster_fsm {
    color=blue;
    label="State Machine";
    node [shape = doublecircle];
    #{accepting_states.join ' '};
    node [shape = circle];
#{edges.join "\n"}
  }

#{memo_nodes.join "\n"}
#{memo_edges.join "\n"}
}
        eodot
      end
    end
  end
end
