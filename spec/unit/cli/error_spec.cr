require "./spec_helper"

describe "error feature" do
  describe "invalid config" do
    it "(put invalid config)" do
      File.write fburlrc, <<-EOF
        [alias]

        [profile]
        access_token =

        EOF
    end
    
    it "should tell about invalid config" do
      app = cli
      expect_raises(Fburl::Errors::InvalidConfig, /Invalid config/) do
        app.run("config show -K #{fburlrc}".split)
      end
    end
  end
end
