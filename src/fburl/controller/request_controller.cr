class Fburl::Controller::RequestController < Fburl::Controller::Base
  def dispatch
    authorize!
    check_subcmds!
    perform_request
  end

  def dryrun
    authorize!
    check_subcmds!
    @output.puts curl_string
    @output.flush
  end

  def perform_request
    client.perform_request_from_options(options) { |response|
      dump_header(response)
      dump_body(response)
    }
  end

  def needs_access_token?
    true
  end

  def check_subcmds!
    if (ary = options.subcmds).any?
      raise Errors::UnknownSubcmds.new(ary.inspect)
    end
  end  

  def curl_string
    lf = "\\\n     "
    String.build do |io|
      io << "curl -s "
      if options.method.get?
        io << "-G "
      else
        io << "-X %s " % options.method.to_s
      end
      io << lf
      options.data.each do |key, val|
        io << "-d '%s=%s' " % [key, val]
        io << lf
      end
      io << "%s%s" % [options.base_url, options.path]
    end    
  end

  private def dump_header(response)
    case file = options.dump
    when nil ; # NOP
    when "-" ; @output.puts response.protocol_header
    else     ; File.write(file, response.protocol_header)
    end
  end
  
  private def dump_body(response)
    print response.body
  end

  Registry["request"] = self
end
