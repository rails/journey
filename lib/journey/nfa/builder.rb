# encoding: utf-8
module Journey
  module NFA
    class TransitionTable
      def initialize
        @table     = Hash.new { |h,f| h[f] = {} }
        @accepting = Hash.new(false)
        @inverted  = nil
      end

      def add_accepting s
        @accepting[s] = true
      end

      def remove_accepting s
        @accepting.delete s
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
          inverted[s].find_all { |sym,_| sym === a }.map(&:last)
        }.flatten
      end

      def edges idx
        inverted[idx]
      end

      ###
      # Returns a set of NFA states reachable from some NFA state +s+ in set
      # +t+ on nil-transitions alone.
      def eclosure t
        Array(t).map { |s|
          edges(s).reject { |sym,_| sym }.map { |_,to|
            [to] + eclosure(to)
          }
        }.flatten
      end

      def to_dot
        edges = @table.map { |to, hash|
          hash.map { |from, sym|
            "#{from} -> #{to} [label=\"#{sym || 'ε'}\"];"
          }
        }.flatten

        nodes = (@table.keys + @table.values.map(&:keys).flatten).uniq.map { |i|
          "#{i} [label=\"#{i.to_s(16)}\"];"
        }

        <<-eodot
digraph nfa {
  rankdir=LR;
  size="8,5"
  node [shape = doublecircle];
  #{@accepting.keys.join ' ' };
  node [shape = circle];
  #{nodes.join "\n"}
  #{edges.join "\n"}
}
        eodot
      end

      private
      def inverted
        return @inverted if @inverted

        @inverted = Hash.new { |h,from| h[from] = [] }
        @table.each { |to, hash|
          hash.each { |from, sym|
            @inverted[from] << [sym, to]
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

        @tt.remove_accepting left.last

        @tt.merge left.last, right.first

        [left.first, right.last]
      end

      def visit_GROUP node
        from  = @i += 1
        left  = visit node.left
        to    = @i += 1

        @tt.remove_accepting left.last
        @tt.add_accepting to

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

        @tt.remove_accepting left.last
        @tt.remove_accepting right.last

        @tt[from, left.first]  = nil
        @tt[from, right.first] = nil
        @tt[left.last, to]     = nil
        @tt[right.last, to]    = nil

        @tt.add_accepting to

        [from, to]
      end

      def terminal node
        from_i = @i += 1 # new state
        to_i   = @i += 1 # new state

        @tt[from_i, to_i] = node
        @tt.add_accepting to_i

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
