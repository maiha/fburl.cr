record Fburl::OAuthClient,
  try_rc : Try(RCFile) do

  delegate profile, aliases, to: rc
  delegate access_token?, to: profile

  def rc
    try_rc.get
  end
  
  def perform_request_from_options(options)
    client = HTTP::Client.new(options.host, tls: true)
    if options.method.get?
#      client.get(options.request_path)
    else
    end

    yield options
  end
end
