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
      options.data["access_token"] = token
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
end
