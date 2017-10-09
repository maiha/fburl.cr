require "./**"

class Facebook::Client
  include Authorize
  include Commands::Get
  include Commands::Post

  property options : Options

  def self.new(args : String)
    new(args.split(/\s+/))
  end
  
  def initialize(args : Array(String))
    @options = Options.parse!(args)
    if options.commands.any?
      raise Errors::UnknownCommand.new(options.commands.join(","))
    end
    authorize!
  end

  def execute : HTTP::Client::Response
    if options.method.get?
      get(options)
    elsif options.method.post?
      post(options)
    else
      puts "# DEBUG: options"
      p options
      raise Errors::NotImplemented.new("Method(%s)" % options.method)
    end
  end

  def execute(request : HTTP::Request, client : HTTP::Client? = nil) : HTTP::Client::Response
    request.headers["Host"] ||= options.host
    request.headers["UserAgent"] ||= options.ua

    client ||= HTTP::Client.new(options.uri)
    client.exec(request)
  end
end
