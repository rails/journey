require 'strscan'

module Journey
  module NFA
    class Simulator
      attr_reader :tt

      def initialize transition_table
        @tt = transition_table
      end

      def simulate string
        input = StringScanner.new string
        state = tt.eclosure 0
        until input.eos?
          sym   = input.scan(/[\/\.\?]|[^\/\.\?]+/)

          # FIXME: tt.eclosure is not needed for the GTG
          state = tt.eclosure tt.move(state, sym)
        end

        tt.accepting == state.sort.last
      end

      alias :=~    :simulate
      alias :match :simulate
    end
  end
end
