require 'rack/route/definition/scanner'

module Rack
  module Route
    module Definition
      module Nodes
        class Node < Struct.new(:children)
          def initialize children = []
            super
          end
        end
        class Path < Node; end
      end

      class Parser < Racc::Parser
        def initialize
          @scanner = Definition::Scanner.new
        end

        def parse string
          @scanner.scan_setup string
          do_parse
        end

        def next_token
          @scanner.next_token
        end
      end
    end
  end
end
