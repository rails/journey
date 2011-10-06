require 'journey/nfa/dot'

module Journey
  module GTG
    class TransitionTable
      include Journey::NFA::Dot

      attr_reader :memos

      def initialize
        @regexp_states = Hash.new { |h,k| h[k] = {} }
        @string_states = Hash.new { |h,k| h[k] = {} }
        @accepting  = {}
        @memos      = Hash.new { |h,k| h[k] = [] }
      end

      def add_accepting state
        @accepting[state] = true
      end

      def accepting_states
        @accepting.keys
      end

      def accepting? state
        @accepting[state]
      end

      def add_memo idx, memo
        @memos[idx] << memo
      end

      def memo idx
        @memos[idx]
      end

      def eclosure t
        Array(t)
      end

      def move t, a
        t = Array(t)
        move_string(t, a) + move_regexp(t, a)
      end

      def []= from, to, sym
        case sym
        when String, NilClass
          @string_states[from][sym] = to
        when Regexp
          @regexp_states[from][sym] = to
        else
          raise ArgumentError, 'unknown symbol: %s' % sym.class
        end
      end

      def states
        ss = @string_states.keys + @string_states.values.map(&:values).flatten
        rs = @regexp_states.keys + @regexp_states.values.map(&:values).flatten
        (ss + rs).uniq
      end

      def transitions
        @string_states.map { |from, hash|
          hash.map { |s, to| [from, s, to] }
        }.flatten(1) + @regexp_states.map { |from, hash|
          hash.map { |s, to| [from, s, to] }
        }.flatten(1)
      end

      private
      def move_regexp t, a
        t.map { |s|
          @regexp_states[s].find_all { |re,_| re === a }.map(&:last)
        }.flatten.uniq
      end

      def move_string t, a
        t.map { |s| @string_states[s][a] }.compact
      end
    end
  end
end
