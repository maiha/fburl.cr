require "./base"

class Fburl::Controller::ConfigController < Fburl::Controller::Base
  val authorize = false
  val subcmds   = true

  SUB_COMMANDS = Array(String).new

  def dispatch
    {% for method in @type.methods.select(&.visibility.== :protected) %}
      return {{method.name.id}} if options.subcmds == ["{{method.name.id}}"]
    {% end %}

    help
  end

  protected def init
    path = File.expand_path(options.rcpath)
    if File.exists?(path)
      rc = RCFile.load(path)
      rc.save
      puts "Reinitialized config in %s" % path
    else
      rc = RCFile.new(path)
      rc.save
      puts "Initialized empty config in %s" % path
    end
  end

  protected def show
    puts "# %s" % options.rcpath
    puts RCFile.load(options.rcpath).to_s
  end

  protected def help
    subs = SUB_COMMANDS.join(", ")
    puts <<-EOF
      Usage: #{$0} config [commands]

      Commands:
        #{ subs }
      EOF
  end

  {% for method in @type.methods.select(&.visibility.== :protected) %}
    SUB_COMMANDS << {{ method.name.stringify }}
  {% end %}

  Registry["config"] = self
end
