require 'journey/nfa/dot'

module Journey
  module NFA
    class TransitionTable
      include Journey::NFA::Dot

      attr_accessor :accepting

      def initialize
        @table     = Hash.new { |h,f| h[f] = {} }
        @accepting = nil
        @inverted  = nil
      end

      def []= i, f, s
        @table[f][i] = s
      end

      def merge left, right
        @table[right] = @table.delete(left)
      end

      def states
        @table.map { |s,v| [s] + v.keys }.flatten.uniq
      end

      ###
      # Returns a generalized transition graph with reduced states.  The states
      # are reduced like a DFA, but the table must be simulated like an NFA.
      #
      # Edges of the GTG are regular expressions
      def generalized_table
        gt       = GeneralizedTable.new
        marked   = {}
        state_id = Hash.new { |h,k| h[k] = h.length }
        alphabet = self.alphabet

        stack = [eclosure(0)]

        until stack.empty?
          state = stack.pop
          next if marked[state] || state.empty?

          marked[state] = true

          alphabet.each do |alpha|
            next_state = eclosure(following_states(state, alpha))
            next if next_state.empty?

            gt[state_id[state], state_id[next_state]] = alpha
            stack << next_state
          end
        end

        accepting = state_id.length + 1

        state_id.each do |states, id|
          if states.include? self.accepting
            gt[id, accepting] = nil
          end
        end

        gt.accepting = accepting

        gt
      end

      ###
      # Returns set of NFA states to which there is a transition on ast symbol
      # +a+ from some state +s+ in +t+.
      def following_states t, a
        Array(t).map { |s|
          edges_on(s).find_all { |sym,_| sym && sym.symbol == a }.map(&:last)
        }.flatten.uniq
      end

      ###
      # Returns set of NFA states to which there is a transition on ast symbol
      # +a+ from some state +s+ in +t+.
      def move t, a
        Array(t).map { |s|
          edges_on(s).find_all { |sym,_| sym && sym.symbol === a }.map(&:last)
        }.flatten.uniq
      end

      def alphabet
        inverted.values.flatten(1).find_all { |sym,state|
          sym
        }.map(&:first).map { |s|
          Nodes::Symbol === s ? s.regexp : s.left
        }.uniq
      end

      ###
      # Returns a set of NFA states reachable from some NFA state +s+ in set
      # +t+ on nil-transitions alone.
      def eclosure t
        children = Array(t).map { |s|
          edges_on(s).reject { |sym,_| sym }.map { |_,to|
            [to] + eclosure(to)
          }
        }.flatten

        (children + Array(t)).uniq
      end

      def transitions
        @table.map { |to, hash|
          hash.map { |from, sym| [from, sym, to] }
        }.flatten(1)
      end

      private
      def edges_on idx
        inverted[idx] || []
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
  end
end
