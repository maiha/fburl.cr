
TMP_DIR = "#{__DIR__}/../../tmp/spec"
Dir.mkdir_p TMP_DIR

def empty_array
  Array(String).new
end

def empty_hash
  Hash(String, String).new
end

def fburlrc
  tmp_file "fburlrc"
end

def cli
  Fburl::CLI.new(exit_on_error: false, output: IO::Memory.new)
end

def tmp_file(name) : String
  File.join(TMP_DIR, name)
end

def prepare_rcfile(access_token : String?)
  it "(prepare rcfile with access_token=#{access_token})" do
    path = tmp_file "fburlrc"

    if access_token
      # write
      File.write path, <<-EOF
        [profile]
        access_token = "#{access_token}"
        EOF

      # verify
      rc = Fburl::RCFile.load(path)
      rc.profile.access_token.should eq(access_token)

    else
      File.delete(path) if File.exists?(path)
    end
  end
end
