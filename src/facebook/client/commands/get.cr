class Facebook::Client
  module Commands::Get
    protected def get(options : Options) : HTTP::Client::Response
      res = get(options.request_path)
      if options.paging && res.status_code == 200
        get_next_pages(options, res)
      elsif !options.rawdata && res.status_code == 200
        extract_data_wrapper(res)
      else
        res
      end
    end

    private def get(path : String)
      execute(HTTP::Request.new("GET", path))
    end

    private def get(uri : URI)
      execute(HTTP::Request.new("GET", uri.full_path), HTTP::Client.new(uri))
    end

    private def get_next_pages(options, res) : HTTP::Client::Response
      data = IO::Memory.new
      url  = accumulate_data_and_return_next!(data, res.body) || return res

      # we have already finished `GET` for 1st page
      (2..options.maxpage).each do |page|
        if url
          res = get(URI.parse(url))
          res.headers["X-FBURL-PAGE"] = page.to_s
          return res if res.status_code != 200
          url = accumulate_data_and_return_next!(data, res.body)
        else
          break
        end
      end

      # closing data
      data << (data.pos == 0 ? "null" : "]")
      body = String.new(data.to_slice)
      body = String.build{|io| io << "{\"data\": " << body << "}"  } if options.rawdata

      # build accumulated response
      build_response(res, body)
    end

    # body: "{data: ...}" => "..."
    private def extract_data_wrapper(res) : HTTP::Client::Response
      body = JSON.parse(res.body)["data"]?.try(&.to_json) || return res
      build_response(res, body)
    end

    private def accumulate_data_and_return_next!(io, body) : String?
      json = JSON.parse(body)    
      if data = json["data"]?.try(&.as_a)
        data.each do |v|
          joint = (io.pos == 0) ? "[" : ","
          io << joint << v.to_json << "\n"
        end
      end

      if paging = json["paging"]?
        if n = paging["next"]?
          return n.as_s
        end
      end

      return nil
    end

    private def build_response(res : HTTP::Client::Response, body : String)
      headers = res.headers
      headers.delete("Content-Encoding")
      headers.delete("Content-Length")

      HTTP::Client::Response.new(res.status_code, body: body, headers: headers)
    end
  end
end
