require "spec"
require "../src/fburl"

TMP_DIR = "#{__DIR__}/../tmp/spec"
Dir.mkdir_p TMP_DIR

def empty_array
  Array(String).new
end

def empty_hash
  Hash(String, String).new
end

def tmp_file(name) : String
  File.join(TMP_DIR, name)
end

def fburlrc
  tmp_file "fburlrc"
end

def cli
  Fburl::CLI.new(exit_on_error: false, output: IO::Memory.new)
end
