class Facebook::Client
end

require "./**"

class Facebook::Client
  include Execute

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
  end

  def merge(args : String? = nil) : Facebook::Client
    merge(args.to_s.strip.split(/\s+/))
  end

  def merge(args : Array(String)) : Facebook::Client
    args.reject!(&.== "")
    self.class.new(original_args + args)
  end
end
