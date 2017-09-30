class Fburl::Options
  SUPPORTED_COMMANDS = Controller::Registry.keys

  property protocol : String  = "https"
  property host     : String  = "graph.facebook.com"
  property method   : Method  = Method::GET
  property command  : String  = "request"
  property path     : String? = nil
  property data     : Data    = Data.new
  property rcpath   : String  = "~/.fburlrc"
  property subcmds  : Subcmds = Subcmds.new
  property? access_token : String? = nil

  def path!
    path || raise Errors::PathNotFound.new
  end
  
  def command!
    unless SUPPORTED_COMMANDS.includes?(@command)
      raise Errors::UnknownCommand.new("'%s' (%s)" % [@command, SUPPORTED_COMMANDS.join(", ")])
    end
    return @command
  end
  
  def ssl?
    protocol == "https"
  end

  def base_url
    "#{protocol}://#{host}"
  end

  def request_path
    case method
    when .get?
      params = Array(String).new
      data.each do |key, value|
        params << "%s=%s" % [URI.escape(key), URI.escape(value)]
      end
      delimiter = path.includes?("?") ? "&" : "?"
      path + delimiter + params.join("&")
    else
      path
    end
  end
end
