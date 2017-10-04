require "./spec_helper"

describe Fburl do
  describe ".request" do
    it "build RequestController" do
      req = Fburl.request("/v1/foo -a xyz")
      req.should be_a(Fburl::Controller::RequestController)
      req.options.path.should eq("/v1/foo")
      req.options.data.should eq({"access_token" => "xyz"})
    end
  end
end
