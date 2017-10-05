require "http/client"
require "uri"
require "yaml"

require "app"
require "try"
require "toml-config"
require "pretty"
require "jq"

require "./ext/*"
require "./fburl/*"

module Fburl
  alias Data    = Hash(String, String)
  alias Subcmds = Array(String)
end
