class Fburl::Options
  SUPPORTED_COMMANDS = Controller::Registry.keys
  USER_AGENT = "fburl/%s" % Shard.version

  property ua       : String  = USER_AGENT
  property dump     : String? = nil
  property uri      : URI     = URI.parse("https://graph.facebook.com")
  property method   : Method  = Method::GET
  property command  : String  = "request"
#  property batch    : String? = nil
  property path     : String? = nil
  property data     : Data    = Data.new
  property form     : Data    = Data.new
  property rcpath   : String  = "~/.fburlrc"
  property subcmds  : Subcmds = Subcmds.new
  property paging   : Bool    = false
  property maxpage  : Int32   = 50
  property rawdata  : Bool    = false
  property colorize : Bool    = false
  property? access_token : String? = nil

  def batch?
    form["batch"]?
  end

  def path!
    path || raise Errors::PathNotFound.new
  end
  
  def command!
    unless SUPPORTED_COMMANDS.includes?(@command)
      raise Errors::UnknownCommand.new("'%s' (%s)" % [@command, SUPPORTED_COMMANDS.join(", ")])
    end
    return @command
  end

  def host : String
    uri.host || raise Errors::InvalidOption.new("uri.host is not set")
  end

  def base_url
    uri.to_s
  end

  def request_path
    case method
    when .get?
      params = Array(String).new
      data.each do |key, value|
        params << "%s=%s" % [URI.escape(key), URI.escape(value)]
      end
      delimiter = path!.includes?("?") ? "&" : "?"
      path! + delimiter + params.join("&")
    else
      path!
    end
  end
end
