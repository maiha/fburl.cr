require "./**"

class Facebook::Client
  include Authorize
  include Commands::Get
  include Commands::Post
  include Commands::Batch

  property options : Options

  def self.new(args : String)
    new(args.strip.split(/\s+/))
  end

  getter original_args : Array(String)
  
  def initialize(args : Array(String) = Array(String).new)
    @original_args = args.dup
    @options = Options.parse!(args)
    if options.commands.any?
      raise Errors::UnknownCommand.new(options.commands.join(","))
    end
    authorize!
  end

  def merge(args : String) : Facebook::Client
    merge(args.strip.split(/\s+/))
  end

  def merge(args : Array(String)) : Facebook::Client
    self.class.new(original_args + args)
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

  def execute(args : String) : HTTP::Client::Response
    merge(args).execute
  end

  def execute(args : Array(String)) : HTTP::Client::Response
    merge(args).execute
  end
end
