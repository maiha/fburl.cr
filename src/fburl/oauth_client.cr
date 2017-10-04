record Fburl::OAuthClient,
  try_rc : Try(RCFile) do

  delegate profile, aliases, to: rc
  delegate access_token?, to: profile

  def rc
    try_rc.get
  end
  
  def execute(options : Options) : HTTP::Client::Response
    client = HTTP::Client.new(options.host, tls: true)
    if options.method.get?
      return client.get(options.request_path)
    else
      puts "# DEBUG: options"
      p options
      raise Errors::NotImplemented.new("Method(%s)" % options.method)
    end
  end
end
