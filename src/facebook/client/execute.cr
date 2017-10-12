module Facebook::Client::Execute
  def execute : HTTP::Client::Response
    options.authorize!
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
    client.compress = options.compress
    client.exec(request)
  end

  def execute(args : String) : HTTP::Client::Response
    merge(args).execute
  end

  def execute(args : Array(String)) : HTTP::Client::Response
    merge(args).execute
  end
end
