require "./spec_helper"

private def config_body : String
  <<-EOF
    [alias]
    me = "/v2.15/me"

    [profile]
    access_token = ""

    EOF
end

describe "config usage" do
  describe "show" do
    it "(put config)" do
      File.write fburlrc, config_body
    end
    
    it "should print config body" do
      app = cli
      app.run("config show -K #{fburlrc}".split)
      app.output.to_s.should contain(config_body)
    end
  end
end
