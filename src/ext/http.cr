class HTTP::Client::Response
  def protocol_header : String
    String.build{|io| to_io(io)}.split(/\r?\n\r?\n/).first
  end
end
