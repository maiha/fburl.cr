class Facebook::Options::Parser
  include Opts2

  property opts : Options = Options.new
  
  option uri     : String , "-H URI" , "Request host", "https://graph.facebook.com"
  option method  : String , "-X METHOD" , "Request method", "GET"
  option data    : Data   , "-d DATA", "POST query data" do extract_data!(v); end
  option form    : Data   , "-F FORM", "POST form data" do extract_form!(v); end
  option atoken  : String?, "-a TOKEN", "Your access token", nil
  option rcpath  : String , "-K PATH" , "The path of config file", "~/.fburlrc"
  option rawdata : Bool   , "--raw", "Print raw response without stripping '.data'", false
  option paging  : Bool   , "--next", "Follow next paging link", false
  option maxpage : Int32  , "--max-next COUNT", "Max number of next paging", 50

  def self.parse!(args : Array(String))
    obj = new
    obj.parse!(args)
    return obj.opts
  end
  
  def parse!(args)
    option_parser.parse(args)

    opts.rcpath       = rcpath
    opts.try_config   = Try(Config).try{ Config.load(opts.rcpath) }
    opts.access_token = atoken || opts.config_access_token?

    opts.uri          = URI.parse(uri)
    opts.method       = Method.parse(self.method)
    opts.rawdata      = rawdata
    opts.paging       = paging
    opts.maxpage      = maxpage

    opts.data.merge!(data)
    opts.form.merge!(form)

    extract_path!(args)
    opts.commands = args
  end

  private def extract_data!(arg)
    case arg
    when /^(.*?)=(.*)$/
      opts.data[$1] = $2
    else
      raise Errors::EqualNotFound.new(arg)
    end
  end

  private def extract_form!(arg)
    self.method = "POST"
    case arg
    when /^(.*?)=(.*)$/
      opts.form[$1] = $2
    else
      raise Errors::EqualNotFound.new(arg)
    end
  end

  private def extract_path!(args)
    args.each_with_index do |arg, i|
      case arg
      when /^(\/[^?]*)(\?(.*))?/
        path = $1
        if params = $~[3]?
          path += "?" + escape_params(params)
        end
        opts.path = path
        args.delete_at(i)
        break
      end
    end
  end
  
  private def escape_params(params)
    split_params = params.split("&").map do |param|
      ary = param.split("=", 2)
      ary.map{|i| URI.escape(i)}.join("=")
    end
    split_params.join("&")
  end
end

class Facebook::Options
  def self.parse!(args : String) : Options
    parse!(args.split(/\s+/))
  end

  def self.parse!(args : Array(String)) : Options
    Parser.parse!(args)
  end
end
