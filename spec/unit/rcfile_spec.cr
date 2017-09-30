require "./spec_helper"

describe Fburl::RCFile do
  describe ".load(toml)" do
    context "(when valid file exists)" do
      it "provides access_token" do
        path = tmp_file "fburlrc"
        File.write path, <<-EOF
          [alias]
          foo = "/v1/foo"
          bar = "/v1/bar -d a=1"

          [profile]
          access_token = "abc"
          EOF
        rc = Fburl::RCFile.load(path)
        rc.profile.access_token.should eq("abc")
        rc.aliases.should eq({"foo" => "/v1/foo", "bar" => "/v1/bar -d a=1"})
      end
    end
  end
end
