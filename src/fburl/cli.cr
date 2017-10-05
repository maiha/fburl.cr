require "./controller/*"

class Fburl::CLI
  include Opts

  property try_rc : Try(RCFile) = Try(RCFile).try { raise "not initialized" }
  property opts : Options = Options.new
  
  def initialize(@output : IO = STDOUT, @exit_on_error : Bool = true, @read_rcfile : Bool = true)
  end

  def output
    @output.not_nil!
  end

  USAGE = <<-EOF
    Usage: {{program}} [options] [commands]

    Commands:
      #{Options::SUPPORTED_COMMANDS.join(", ")}

    Options:
    {{options}}

    Examples:
      (request)
        % {{program}} /v2.15/me
      (alias)
        % {{program}} alias me /v2.15/me
        % {{program}} me
      (config)
        % {{program}} config
    EOF

  option host    : String , "-H HOST" , "Request host", "graph.facebook.com"
  option method  : String , "-X METHOD" , "Request method", "GET"
  option data    : Data   , "-d DATA", "POST data" do extract_data!(v); end
  option atoken  : String?, "-a TOKEN", "Your access token", nil
  option rcpath  : String , "-K PATH" , "The path of config file", "~/.fburlrc"
  option dump    : String?, "-D FILE", "Write http headers to the file", nil
  option dryrun  : Bool   , "-n", "Dryrun with printing curl command", false
  option rawdata : Bool   , "--raw", "Print raw data without formatting", false
  option color   : Bool   , "--color", "Colorize json string", false
  option paging  : Bool   , "--next", "Follow next paging link", false
  option maxpage : Int32  , "--max-next COUNT", "Max number of next paging", 50
  option verbose : Bool   , "-v", "Verbose output", false
  option version : Bool   , "--version", "Print the version and exit", false
  option help    : Bool   , "--help"   , "Output this help and exit" , false

  def setup(argv : String)
    setup(argv.split)
  end

  def setup(argv : Array(String))
    set_rcpath!(argv)
    @try_rc = read_rcfile!
    apply_aliases!(argv)
    super(argv)
  end

  def setup
    extract_path!
    opts.dump = dump
    opts.host = host
    opts.method = Method.parse(self.method)
    opts.access_token = atoken
    opts.data.merge!(data)
    opts.command = args.shift if args.any?
    opts.subcmds = args
    opts.command = "dryrun" if dryrun
    opts.rawdata = rawdata
    opts.colorize = color
    opts.paging  = paging
    opts.maxpage = maxpage
    super() if opts.path.nil?
  end

  def run
    controller.dispatch
  end

  def client
    OAuthClient.new(@try_rc)
  end
  
  def controller
    Controller::Registry[opts.command!].new(client, opts, @output)
  end

  def on_error(err)
    if ! @exit_on_error
      raise err
    elsif err.is_a?(Fburl::Errors::RcfileNotFound)
      @output.puts <<-EOF
        No config file exist. Try following command.
          #{$0} config init
        EOF
    elsif err.is_a?(Fburl::Errors::Base)
      abort "ERROR: #{err}"
    else
      super(err)
    end
  end

  private def extract_data!(arg)
    arg.split("&").each do |pair|
      case pair
      when /^(.*?)=(.*)$/
        opts.data[$1] = $2
      else
        raise Errors::EqualNotFound.new(pair)
      end
    end
  end

  private def extract_path!
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

  private def set_rcpath!(argv)
    # respect argv for "-K"
    # IMPORTANT: use latter one
    argv.each_with_index do |v, idx|
      if v == "-K"
        if idx + 1 < argv.size
          opts.rcpath = argv[idx + 1]
        end
      end
    end
  end

  private def read_rcfile!
    Try(RCFile).try{
      if @read_rcfile
        RCFile.load(opts.rcpath)
      else
        raise "RCFile is disabled by `read_rcfile` option."
      end
    }
  end

  private def apply_aliases!(argv)
    if rc = @try_rc.get?
      if command = self.class.parse_command(argv)
        if idx = argv.index(command)
          # NOTE: here, we should care about the case of `Array` for alias-value.
          # [given]
          #   command      = "help"
          #   (alias) help = "/help -d a=b"
          # [then]
          #   src: ["-K", "foo", "help", "-a", "xxx"]
          #                      ^^^^^^
          #   dst: ["-K", "foo", "/help", "-d", "a=b", "-a", "xxx"]
          #                      ^^^^^^^^^^^^^^^^^^^^
          argv[idx..idx] = (rc.aliases[command]? || command).split
        end
      end
    end
  end

  # `parse_command` return a string without semantics validation.
  # Even if unknown command is detected, this returns it without any exceptions.
  def self.parse_command(argv : Array(String)) : String
    argv = argv.dup
    # IMPORTANT:
    # never forget to set 'read_rcfile = false', otherwise it will cause infinite loop.
    app = new(read_rcfile: false)
    app.setup(argv)
    return app.opts.command
  end
end
