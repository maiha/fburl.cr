record Fburl::OAuthClient,
  try_rc : Try(RCFile) do

  delegate profile, aliases, to: rc
  delegate access_token?, to: profile

  def rc
    try_rc.get
  end

  def execute(options : Options) : HTTP::Client::Response
    if options.method.get?
      get(options)
    else
      puts "# DEBUG: options"
      p options
      raise Errors::NotImplemented.new("Method(%s)" % options.method)
    end
  end

  private def get(options : Options) : HTTP::Client::Response
    client = HTTP::Client.new(options.host, tls: true)
    res = client.get(options.request_path)
    if options.paging && res.status_code == 200
      get_next_pages(options, res)
    else
      res
    end
  end

  private def accumulate_data!(io, body) : String?
    json = JSON.parse(body)    
    json["data"].as_a.each do |v|
      joint = (io.pos == 0) ? "[" : ","
      io << joint << v.to_json << "\n"
    end

    if paging = json["paging"]?
      if n = paging["next"]?
        return n.as_s
      end
    end

    return nil
  end

  private def get_next_pages(options, res) : HTTP::Client::Response
    data = IO::Memory.new
    url  = accumulate_data!(data, res.body) || return res

    # we have already finished `GET` for 1st page
    (2..options.maxpage).each do |page|
      if url
        uri    = URI.parse(url)
        client = HTTP::Client.new(uri)
        res    = client.get(uri.full_path)
        res.headers["X-FBURL-PAGE"] = page.to_s
        return res if res.status_code != 200
        url = accumulate_data!(data, res.body)
      else
        break
      end
    end

    # closing data
    data << (data.pos == 0 ? "null" : "]")
    body = String.build do |io|
      io << "{\"data\": " << String.new(data.to_slice) << "}"
    end

    # build accumulated response
    headers = res.headers
    headers.delete("Content-Encoding")
    headers.delete("Content-Length")

    HTTP::Client::Response.new(res.status_code, body: body, headers: headers)
  end
end
