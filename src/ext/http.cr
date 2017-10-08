module HTTP::FormData::Accessor
  def form_data?
    headers["Content-Type"]? =~ /boundary="(.*?)"/
  end

  val form_data = Hash(String, String).new.tap{|data|
    case headers["Content-Type"]?
    when /boundary="(.*?)"/
      boundary=$1
      HTTP::FormData.parse(body.not_nil!, boundary) do |part|
        data[part.name] = part.body.gets_to_end
      end
    end
  }
end

class HTTP::Client::Response
  def protocol_header : String
    String.build{|io| to_io(io)}.split(/\r?\n\r?\n/).first
  end
end

class HTTP::Request
  include HTTP::FormData::Accessor

  def protocol_body : String
    String.build{|io| to_io(io)}.split(/\r?\n\r?\n/, 2).last
  end
end
