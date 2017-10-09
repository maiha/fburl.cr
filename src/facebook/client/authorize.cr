class Facebook::Client
  module Authorize
    abstract def options : Options

    protected def authorize!
      if token = options.access_token?
        case options.method
        when .get?
          options.data["access_token"] = token
        when .post?
          options.form["access_token"] = token
          if batch = options.form["batch"]?
                       check_json_syntax!(batch)
          end
        else
          raise Errors::NotImplemented.new("#{options.method} method with access_token")
        end
      else
        raise Errors::NotAuthorized.new
      end
    end

    private def check_json_syntax!(buf : String)
      JSON.parse(buf)
    rescue err
      raise Errors::BatchJsonError.new(err.to_s)
    end
  end
end
