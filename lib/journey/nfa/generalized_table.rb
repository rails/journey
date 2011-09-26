module Journey
  module NFA
    class GeneralizedTable
      attr_accessor :accepting

      def initialize
        @dfa_states = Hash.new { |h,k| h[k] = {} }
        @nfa_states = Hash.new { |h,k| h[k] = {} }
        @accepting  = nil
      end

      def states
        states = @dfa_states.map { |state, kv|
          [state] + kv.values
        }.flatten + @nfa_states.map { |state, kv|
          [state] + kv.values
        }.flatten

        states.uniq
      end

      def eclosure t
        t = Array(t)
        t.map { |s| @dfa_states[s][nil] }.compact.uniq + t
      end

      def move t, a
        t = Array(t)
        move_dfa(t, a) + move_nfa(t, a)
      end

      def []= i, f, s
        case s
        when String, NilClass
          @dfa_states[i][s] = f
        when Regexp
          @nfa_states[i][s] = f
        else
          raise ArgumentError, 'unknown symbol: %s' % s.class
        end
      end

      private
      def move_nfa t, a
        t.map { |s|
          @nfa_states[s].find_all { |re,_| re === a }.map(&:last)
        }.flatten.uniq
      end

      def move_dfa t, a
        t.map { |s| @dfa_states[s][a] }
      end
    end
  end
end
