module HTTP::FormData::Accessor
#  func form_data? = headers["Content-Type"]? =~ /boundary="(.*?)"/

  var form_data : Hash(String, String) = build_form_data

  private def build_form_data
    data = Hash(String, String).new
    case headers["Content-Type"]?
    when /boundary="(.*?)"/
      boundary=$1
      HTTP::FormData.parse(body.not_nil!, boundary) do |part|
        data[part.name] = part.body.gets_to_end
      end
    end
    data
  end
end

class HTTP::Client::Response
  var protocol_header = String.build{|io| to_io(io)}.split(/\r?\n\r?\n/).first
end

class HTTP::Request
  include HTTP::FormData::Accessor

  var protocol_body = String.build{|io| to_io(io)}.split(/\r?\n\r?\n/, 2).last
end
