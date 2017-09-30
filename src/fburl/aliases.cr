class Fburl::Aliases < Hash(String, String)
  def to_toml(io : IO)
    io << "[alias]\n"
    lines = map{|k,v| [k, v.inspect]}.sort
    io << Pretty.lines(lines, delimiter: " = ")
    io << "\n\n"
  end
end
