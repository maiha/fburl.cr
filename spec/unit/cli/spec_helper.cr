require "../../spec_helper"

class CLIMock < Fburl::CLI
  def run
  end
end

def mock_cli(buf : String)
  cli = CLIMock.new(exit_on_error: false)
  cli.run(buf.split(/\s+/))
  return cli
end

macro fburl(args)
  it {{args}} do
    opts = mock_cli({{args}}).opts
    {{ yield }}
  end
end

macro fburl(args, aliases)
  it "{{args.id}} with {{aliases.stringify.gsub(/"/,"").id}}" do
    File.open(fburlrc, "w+") do |io|
      io.puts "[alias]"
      {% for k,v in aliases %}
        io << "{{k.id}} = "
        io << {{v.stringify}}
        io << "\n"
      {% end %}
    end
    args = {{args}}.split(/\s+/) + ["-K", fburlrc]
    opts = CLIMock.run(args).opts
    {{ yield }}
  end
end
