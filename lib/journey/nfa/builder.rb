# encoding: utf-8
module Journey
  module NFA
    class TransitionTable
      attr_accessor :accepting

      def initialize
        @table     = Hash.new { |h,f| h[f] = {} }
        @accepting = 0
        @inverted  = nil
      end

      def []= i, f, s
        @table[f][i] = s
      end

      def merge left, right
        @table[right] = @table.delete(left)
      end

      ###
      # Returns set of NFA states to which there is a transition on input symbol
      # +a+ from some state +s+ in +t+.
      def move t, a
        Array(t).map { |s|
          z = edges(s).find_all { |sym,_|
            sym && sym === a
          }.map(&:last)
        }.flatten.uniq
      end

      def alphabet
        inverted.values.flatten(1).find_all { |sym,state|
          sym
        }.map(&:first).map { |s|
          Nodes::Symbol === s ? s.regexp : s.left
        }.uniq
      end

      def edges idx
        inverted[idx] || []
      end

      ###
      # Returns a set of NFA states reachable from some NFA state +s+ in set
      # +t+ on nil-transitions alone.
      def eclosure t
        children = Array(t).map { |s|
          edges(s).reject { |sym,_| sym }.map { |_,to|
            [to] + eclosure(to)
          }
        }.flatten

        (children + Array(t)).uniq
      end

      def to_dot
        edges = @table.map { |to, hash|
          hash.map { |from, sym|
            "#{from} -> #{to} [label=\"#{sym || 'ε'}\"];"
          }
        }.flatten

        nodes = (@table.keys + @table.values.map(&:keys).flatten).uniq.map { |i|
          "#{i} [label=\"#{i}\"];"
        }

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

      def inverted
        return @inverted if @inverted

        @inverted = {}
        @table.each { |to, hash|
          hash.each { |from, sym|
            (@inverted[from] ||= []) << [sym, to]
          }
        }

        @inverted
      end
    end

    class Visitor < Visitors::Visitor
      def initialize tt
        @tt = tt
        @i  = -1
      end

      def visit_CAT node
        left  = visit node.left
        right = visit node.right

        @tt.merge left.last, right.first

        [left.first, right.last]
      end

      def visit_GROUP node
        from  = @i += 1
        left  = visit node.left
        to    = @i += 1

        @tt.accepting = to

        @tt[from, left.first] = nil
        @tt[left.last, to] = nil
        @tt[from, to] = nil

        [from, to]
      end

      def visit_OR node
        from  = @i += 1
        left  = visit node.left
        right = visit node.right
        to    = @i += 1

        @tt[from, left.first]  = nil
        @tt[from, right.first] = nil
        @tt[left.last, to]     = nil
        @tt[right.last, to]    = nil

        @tt.accepting = to

        [from, to]
      end

      def terminal node
        from_i = @i += 1 # new state
        to_i   = @i += 1 # new state

        @tt[from_i, to_i] = node
        @tt.accepting = to_i

        [from_i, to_i]
      end
    end

    class Builder
      def initialize ast
        @ast = ast
      end

      def transition_table
        tt = TransitionTable.new
        Visitor.new(tt).accept @ast
        tt
      end
    end
  end
end
