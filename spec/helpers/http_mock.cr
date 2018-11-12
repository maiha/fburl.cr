def http_mock_listen(timeout = 3)
  listen  = Channel(Int32).new
  request = Channel::Buffered(String).new
  server, port = build_server_and_port(request)

  spawn do
    sleep timeout
    raise "http_mock_listen: timeouted #{timeout} sec"
  end
  
  # start http server in background
  spawn do
    server.listen
  end

  # wait until http server is up
  spawn do
    loop do
      sleep 0.1
      if port != 0
        listen.send(port)
        break
      end
    end
  end

  # wait until 
  loop do
    select
    when port = listen.receive
      yield port
      server.close
      break
    end
  end  

  io = IO::Memory.new(request.receive)
  return HTTP::Request.from_io(io).as(HTTP::Request).not_nil!
end

private def build_server_and_port(request)
  server = HTTP::Server.new do |ctx|
    ctx.response.content_type = "javascript"
    ctx.response.print "{}"

    io = IO::Memory.new
    ctx.request.to_io(io)
    request.send(String.new(io.to_slice))
  end

  bound = server.bind_tcp("127.0.0.1", 0)
  return {server, bound.port}
end
