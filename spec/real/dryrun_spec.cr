require "./spec_helper"

private def dryrun(cmd : String, expect : String)
  it cmd do
    client = Facebook::Client.new("-K #{fburlrc}")
    client.dryrun(cmd).to_s.should eq(expect)
  end
end

describe "(dryrun)" do
  prepare_rcfile access_token: "xyz"

  context "(GET)" do
    dryrun "/v1", "curl -s -G -d 'access_token=xyz' https://graph.facebook.com/v1"
  end

  context "(POST)" do
    dryrun "/v1/me -F fields=id,name", "curl -s -X POST -F 'fields=id,name' -F 'access_token=xyz' https://graph.facebook.com/v1/me"
  end

  context "(POST: BATCH)" do
    dryrun %(-F batch=[{"method":"GET","relative_url":"me"}]),
      "curl -s -X POST -F 'batch=[{\"method\":\"GET\",\"relative_url\":\"me\"}]' -F 'access_token=xyz' https://graph.facebook.com"

    dryrun %(-F batch=[{"method":"GET","relative_url":"v2.10/act_123/campaigns?fields=account_id%2Ceffective_status&effective_status=%5B%22ACTIVE%22%5D"}]),
      "curl -s -X POST -F 'batch=[{\"method\":\"GET\",\"relative_url\":\"v2.10/act_123/campaigns?fields=account_id%2Ceffective_status&effective_status=%5B%22ACTIVE%22%5D\"}]' -F 'access_token=xyz' https://graph.facebook.com"
  end

  context "(without authorization)" do
    it "raises NotAuthorized" do
      expect_raises(Facebook::Errors::NotAuthorized) do
        Facebook::Client.new.dryrun
      end
    end
  end
end
