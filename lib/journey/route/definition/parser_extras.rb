require 'journey/route/definition/scanner'
require 'journey/route/definition/node'

module Journey
  module Route
    module Definition
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
