require 'journey/nfa/dot'

module Journey
  module NFA
    class GeneralizedTable
      include Journey::NFA::Dot

      attr_accessor :accepting

      def initialize
        @regexp_states = Hash.new { |h,k| h[k] = {} }
        @string_states = Hash.new { |h,k| h[k] = {} }
        @accepting  = nil
      end

      def eclosure t
        t = Array(t)
        t.map { |s| @regexp_states[s][nil] }.compact.uniq + t
      end

      def move t, a
        t = Array(t)
        move_string(t, a) + move_regexp(t, a)
      end

      def []= i, f, s
        case s
        when String, NilClass
          @regexp_states[i][s] = f
        when Regexp
          @string_states[i][s] = f
        else
          raise ArgumentError, 'unknown symbol: %s' % s.class
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
          @string_states[s].find_all { |re,_| re === a }.map(&:last)
        }.flatten.uniq
      end

      def move_string t, a
        t.map { |s| @regexp_states[s][a] }.compact
      end
    end
  end
end
