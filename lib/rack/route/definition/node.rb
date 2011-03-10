module Rack
  module Route
    module Definition
      class Node < Struct.new(:type, :children) # :nodoc:
        include Enumerable

        ##
        # Loop through the requirements AST
        class Each < Struct.new(:block) # :nodoc:
          def accept node
            block.call node
            send "visit_#{node.type}", node
          end

          private

          def nary node
            node.children.each { |x| accept x }
          end
          alias :visit_PATH :nary
          alias :visit_DOT :nary
          alias :visit_SEGMENT :nary

          def terminal node; end
          alias :visit_STAR :terminal
          alias :visit_LITERAL :terminal
          alias :visit_SYMBOL :terminal

          def visit_GROUP node
            accept node.children
          end
        end

        class String
          def accept node
            send "visit_#{node.type}", node
          end

          def visit_PATH node
            node.children.map { |x| accept x }.join
          end

          def visit_STAR node
            "*" + node.children
          end

          def visit_DOT node
            "." + node.children.map { |x| accept x }.join
          end

          def visit_SEGMENT node
            "/" + node.children.map { |x| accept x }.join
          end

          def visit_LITERAL node
            node.children
          end

          def visit_SYMBOL node
            node.children
          end

          def visit_GROUP node
            "(#{accept node.children})"
          end
        end

        def initialize type, children = []
          super
        end

        def each(&block)
          Each.new(block).accept(self)
        end

        def to_s
          String.new.accept(self)
        end
      end
    end
  end
end
