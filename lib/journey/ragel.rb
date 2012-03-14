module Journey
  class Ragel
    attr_reader :name, :asts

    def initialize name, asts
      @name = name
      @asts = asts

      @action_template = ERB.new <<-EOF
  action <%= action_name %> {
    rb_ary_push(matches, INT2NUM(<%= offset %>));
  }

  <%= rule_name %> = <%= rule %> %<%= action_name %>;
      EOF

      @machine_template = ERB.new <<-EOF
%%{
  machine <%= machine_name %>;
  write data;

<%= rules.join "\n" %>

  main := <%= main %>;
}%%
      EOF

      @source_template = ERB.new <<-EOF
#include <ruby.h>

<%= machine %>

static VALUE parse(VALUE self, VALUE string)
{
  int cs;
  char * p = RSTRING_PTR(string);
  char * pe = p + RSTRING_LEN(string);
  char * eof = pe;

  VALUE matches = rb_ary_new();

  %%{
  write init;
  write exec;
  }%%

  if (RARRAY_LEN(matches) == 0)
    return Qfalse;
  else
    return matches;
}

void Init_router()
{
  VALUE above = rb_path2class("<%= name %>");
  VALUE cParser = rb_define_class_under(above, "Parser", rb_cObject);

  rb_define_method(cParser, "parse", parse, 1);
}
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

    def source
      @source_template.result binding
    end

    private
    def main
      asts.length.times.map { |i|
        "r_#{i}"
      }.join ' | '
    end

    def machine_name
      name.to_s.gsub /:/, ''
    end
  end
end
