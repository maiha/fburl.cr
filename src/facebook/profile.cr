class Facebook::Profile < Hash(String, String)
  def access_token
    self["access_token"]
  end

  def access_token?
    self["access_token"]?
  end

  def access_token=(v : String?)
    if v
      self["access_token"] = v
    else
      delete("access_token")
    end
  end

  def to_toml(io : IO)
    io << "[profile]\n"
    hash  = empty? ? {"access_token" => ""} : self
    lines = hash.map{|k,v| [k, v.inspect]}.sort
    io << Pretty.lines(lines, delimiter: " = ")
    io << "\n\n"
  end
end
