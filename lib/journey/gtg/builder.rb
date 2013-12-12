require 'journey/gtg/transition_table'

module Journey
  module GTG
    class Builder
      DUMMY = Nodes::Dummy.new # :nodoc:

      attr_reader :root, :ast, :endpoints

      def initialize root
        @root         = root
        @ast          = Nodes::Cat.new root, DUMMY
        @followpos    = nil
      end

      def transition_table
        dtrans   = TransitionTable.new
        marked   = {}
        state_id = Hash.new { |h,k| h[k] = h.length }

        start   = root.firstpos
        dstates = [start]
        until dstates.empty?
          s = dstates.shift
          next if marked[s]
          marked[s] = true # mark s

          s.group_by { |state| symbol(state) }.each do |sym, ps|
            u = ps.map { |l| followpos(l) }.flatten
            next if u.empty?

            if u.uniq == [DUMMY]
              from = state_id[s]
              to   = state_id[Object.new]
              dtrans[from, to] = sym

              dtrans.add_accepting to
              ps.each { |state| dtrans.add_memo to, state.memo }
            else
              dtrans[state_id[s], state_id[u]] = sym

              if u.include? DUMMY
                to = state_id[u]

                accepting = ps.find_all { |l| followpos(l).include? DUMMY }

                accepting.each { |accepting_state|
                  dtrans.add_memo to, accepting_state.memo
                }

                dtrans.add_accepting state_id[u]
              end
            end

            dstates << u
          end
        end

        dtrans
      end

      def followpos node
        followpos_table[node]
      end

      private
      def followpos_table
        @followpos ||= build_followpos
      end

      def build_followpos
        table = Hash.new { |h,k| h[k] = [] }
        @ast.each do |n|
          case n
          when Nodes::Cat
            if node = n.left.lastpos
              node.each do |i|
                table[i] += n.right.firstpos
              end
            end
          when Nodes::Star
            if node = n.lastpos
              node.each do |i|
                table[i] += n.firstpos
              end
            end
          end
        end
        table
      end

      def symbol edge
        case edge
        when Journey::Nodes::Symbol
          edge.regexp
        else
          edge.left
        end
      end
    end
  end
end
