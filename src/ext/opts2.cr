module Opts2
  class Parser < OptionParser
    property options : Array(Array(String)) = Array(Array(String)).new

    def to_s(io : IO)
      if banner = @banner
        io << banner
        io << "\n"
      end
      io << Pretty.lines(options, indent: "  ", delimiter: "  ")
    end

    private def append_flag(flag, description)
      options << [flag, description]
    end
  end
  
  # with block works only with `Reference` class
  macro option(name, long, desc)
    var {{name}} = {{name.type}}.new

    def parse_{{name.var.id}}(parser)
      {% if long.stringify =~ /[\s=]/ %}
        parser.on({{long}}, "{{desc.id}} (default: {{name.type}}.new).") {|v| {{ yield }} }
      {% else %}
        parser.on({{long}}, "{{desc.id}}.") {self.{{name.var}} = true}
      {% end %}
    end
  end

  macro option(name, long, desc, default)
    var {{name}} = {{default}}

    {% if name.type.stringify == "Bool" %}
      def {{name.var.id}}? ; {{name.var.id}} ; end
    {% end %}
    
    def parse_{{name.var.id}}(parser)
      {% if long.stringify =~ /[\s=]/ %}
        {% if name.type.stringify == "Int64" %}
          parser.on({{long}}, "{{desc.id}} (default: {{default.id}}).") {|x| self.{{name.var}} = x.to_i64}
        {% elsif name.type.stringify.starts_with?("Int32") %}
          parser.on({{long}}, "{{desc.id}} (default: {{default.id}}).") {|x| self.{{name.var}} = x.to_i32}
        {% elsif name.type.stringify == "Int16" %}
          parser.on({{long}}, "{{desc.id}} (default: {{default.id}}).") {|x| self.{{name.var}} = x.to_i16}
        {% elsif name.type.stringify =~ /::Nil$/ %}
          parser.on({{long}}, "{{desc.id}}.") {|x| self.{{name.var}} = x}
        {% else %}
          parser.on({{long}}, "{{desc.id}} (default: {{default.id}}).") {|x| self.{{name.var}} = x}
        {% end %}
      {% else %}
        parser.on({{long}}, "{{desc.id}}.") {self.{{name.var}} = true}
      {% end %}
    end
  end

  macro option(name, short, long, desc, default)
    var {{name}} = {{default}}

    {% if name.type.stringify == "Bool" %}
      def {{name}}? ; {{name}} ; end
    {% end %}
    
    def parse_{{name.var.id}}(parser)
      {% if long.stringify =~ /[\s=]/ %}
        {% if name.type.stringify == "Int64" %}
          parser.on({{short}}, {{long}}, "{{desc.id}} (default: {{default.id}}).") {|x| self.{{name.var}} = x.to_i64}
        {% elsif name.type.stringify == "Int32" %}
          parser.on({{short}}, {{long}}, "{{desc.id}} (default: {{default.id}}).") {|x| self.{{name.var}} = x.to_i32}
        {% elsif name.type.stringify == "Int16" %}
          parser.on({{short}}, {{long}}, "{{desc.id}} (default: {{default.id}}).") {|x| self.{{name.var}} = x.to_i16}
        {% elsif name.type.stringify =~ /::Nil$/ %}
          parser.on({{short}}, {{long}}, "{{desc.id}}.") {|x| self.{{name.var}} = x}
        {% else %}
          parser.on({{short}}, {{long}}, "{{desc.id}} (default: {{default.id}}).") {|x| self.{{name.var}} = x}
        {% end %}
      {% else %}
         parser.on({{short}}, {{long}}, "{{desc.id}}.") {self.{{name.var}} = true}
      {% end %}
    end
  end

  @option_parser : OptionParser?

  protected def option_parser
    @option_parser ||= new_option_parser
  end

  def new_option_parser : OptionParser
    Parser.new.tap{|p|
      {% for methods in ([@type] + @type.ancestors).map(&.methods.map(&.name.stringify)) %}
        {% for name in methods %}
          {% if name =~ /\Aparse_/ %}
            {{name.id}}(p)
          {% end %}
        {% end %}
      {% end %}
    }
  end
end
