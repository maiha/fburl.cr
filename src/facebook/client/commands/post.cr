class Facebook::Client
  module Commands::Post
    protected def post(options : Options) : HTTP::Client::Response
      headers = HTTP::Headers.new
      
      body = String.build do |io|
        HTTP::FormData.build(io) do |builder|
          headers["Content-Type"] = builder.content_type
          options.form.each do |k,v|
            builder.field(k, v)
          end
        end
      end

      path = options.batch? ? "/" : options.request_path
      request = HTTP::Request.new(options.method.to_s, path, headers, body)
      execute(request)
    end
  end
end
