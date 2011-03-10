require 'rack/route/definition/scanner'

module Rack
  module Route
    module Definition
      class Node < Struct.new(:type, :children)
        def initialize type, children = []
          super
        end
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
