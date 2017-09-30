require "./spec_helper"

describe "basic usage" do
  describe "basic usage" do
    it "(delete config)" do
      File.delete(fburlrc) if File.exists?(fburlrc)
    end
    
    it "(clean up)" do
      File.exists?(fburlrc).should be_false
      cli.run("config init -K #{fburlrc}".split)
      File.exists?(fburlrc).should be_true
    end
    
    it "alias me /v2.5/me" do
      cli.run("alias me /v2.5/me -K #{fburlrc}".split)

      File.read(fburlrc).should eq <<-EOF
        [alias]
        me = "/v2.5/me"

        [profile]
        access_token = ""


        EOF
    end
  end
end
