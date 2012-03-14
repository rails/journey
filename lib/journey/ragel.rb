module Journey
  class Ragel
    attr_reader :name, :asts

    def initialize name, asts
      @name = name
      @asts = asts

      @action_template = ERB.new <<-EOF
  action <%= action_name %> {
    rb_funcall(self, rb_intern("match"), 1, INT2NUM(<%= offset %>));
  }

  <%= rule_name %> = <%= rule %> %<%= action_name %>;
      EOF

      @machine_template = ERB.new <<-EOF
%%{
  machine <%= name %>;
  write data;

<%= rules.join "\n" %>

  main := <%= main %>;
}%%
      EOF
    end

    def rules
      viz = Journey::Visitors::Ragel.new
      asts.each_with_index.map { |ast, offset|
        action_name = "r_#{offset}"
        rule_name   = action_name
        rule        = viz.accept ast

        @action_template.result(binding)
      }
    end

    def machine
      @machine_template.result binding
    end

    private
    def main
      asts.length.times.map { |i|
        "r_#{i}"
      }.join ' | '
    end
  end
end
