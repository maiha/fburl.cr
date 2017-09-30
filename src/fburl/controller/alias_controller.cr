require "./base"

class Fburl::Controller::AliasController < Fburl::Controller::Base
  def dispatch
    case options.subcmds.size
    when 0
      show
    when 1
      register(options.subcmds.first)
    else
      pp options
    end
  end

  def dryrun
  end

  def needs_access_token?
    false
  end

  private def show
    client.aliases.each do |key, val|
      @output.puts %(%s = "%s") % [key, val]
    end
  end

  private def register(name)
    ary = [options.path]
    options.data.each do |k,v|
      ary << "-d" << "#{k}=#{v}"
    end

    rc.aliases[name] = ary.join(" ")
    rc.save
  end

  Registry["alias"] = self
end
