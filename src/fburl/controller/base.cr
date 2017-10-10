abstract class Fburl::Controller::Base
  delegate rc, to: client
  delegate puts, to: @output

  def initialize(@client : OAuthClient, @options : Options, @output : IO)
    authorize! if authorize
    subcmds!   unless subcmds
  end

  property client
  property options
  property output

  abstract def dispatch
  abstract def authorize
  abstract def subcmds

  protected def authorize!
    if token = access_token?
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

  protected def subcmds!
    if (ary = options.subcmds).any?
      raise Errors::UnknownSubcmds.new(ary.inspect)
    end
  end  

  protected def access_token?
    options.access_token? || client.access_token?
  end

  protected def check_json_syntax!(buf : String)
    JSON.parse(buf)
  rescue err
    raise Errors::BatchJsonError.new("#{err}: '#{buf}'")
  end
end
