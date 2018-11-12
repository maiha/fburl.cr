class Facebook::Config
  property profile : Profile = Profile.new
  property aliases : Aliases = Aliases.new
  property path    : String
  
  def initialize(@path : String = "~/.fburlrc")
  end

  def realpath
    File.expand_path(@path)
  end

  def load : Config
    toml = TOML::Config.parse_file(realpath)
    load_profile!(toml)
    load_aliases!(toml)
    return self
  rescue err : TOML::ParseException
    raise Errors::InvalidConfig.new("(%s) %s" % [realpath, err])
  end

  def save
    File.write(realpath, to_s)
  end

  def to_s(io : IO)
    aliases.to_toml(io)
    profile.to_toml(io)
  end

  private def load_aliases!(toml)
    hash = toml.as_hash("alias") rescue Aliases.new
    hash.each do |key, val|
      aliases[key] = val.to_s
    end
  end

  private def load_profile!(toml)
    hash = toml.as_hash("profile") rescue Profile.new
    hash.each do |key, val|
      profile[key] = val.to_s
    end
  end
end

class Facebook::Config
  def self.load(path : String) : Config
    rc = new(path)
    raise Errors::ConfigNotFound.new(path) unless File.exists?(rc.realpath)
    rc.load
    return rc
  end
end
