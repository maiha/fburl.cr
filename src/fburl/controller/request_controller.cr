class Fburl::Controller::RequestController < Fburl::Controller::Base
  val authorize = true
  val subcmds   = false

  def dispatch
    response = execute
    dump_header(response)
    dump_body(response)
  end

  def execute : HTTP::Client::Response
    client.execute(options)
  end

  private def dump_header(response)
    case file = options.dump
    when nil ; # NOP
    when "-" ; @output.puts response.protocol_header
    else     ; File.write(file, response.protocol_header)
    end
  end
  
  private def dump_body(response)
    if options.rawdata
      print response.body
    elsif options.colorize
      puts Pretty.json(response.body, color: true)
    else
      puts Pretty.json(response.body)
    end
  end

  Registry["request"] = self
end
