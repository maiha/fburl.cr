class Facebook::Options
  def authorize!
    if token = access_token?
      case method
      when .get?
        data["access_token"] = token
      when .post?
        form["access_token"] = token
        if batch = form["batch"]?
           check_json_syntax!(batch)
        end
      else
        raise Errors::NotImplemented.new("#{method} method with access_token")
      end
    else
      raise Errors::NotAuthorized.new
    end
  end

  private def check_json_syntax!(buf : String)
    JSON.parse(buf)
  rescue err
    raise Errors::BatchJsonError.new("#{err}: '#{buf}'")
  end
end
