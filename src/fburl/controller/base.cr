abstract class Fburl::Controller::Base
  delegate rc, to: client
  delegate puts, to: @output

  def initialize(@client : OAuthClient, @options : Options, @output : IO)
  end

  property client
  property options
  property output

  abstract def dispatch
  abstract def needs_access_token?

  protected def authorize!
    if needs_access_token?
      if token = access_token?
        options.data["access_token"] = token
      else
        raise Errors::NotAuthorized.new
      end
    end
  end

  protected def access_token?
    options.access_token? || client.access_token?
  end
end
