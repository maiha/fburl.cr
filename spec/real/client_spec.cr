require "./spec_helper"

private def client(arg : String, expect : Spec::HttpExpectation)
  it arg do
    http_client(arg).should expect
  end
end

describe "(in http server)" do
  prepare_rcfile access_token: "xyz"

  context "(GET)" do
    client "/v1"         , http("GET /v1?access_token=xyz")
    client "/v1 -d a=1"  , http("GET /v1?a=1&access_token=xyz")
    client "/v1 -d a=1:2", http("GET /v1?a=1%3A2&access_token=xyz")
    client "/v1 -d a=x=1", http("GET /v1?a=x%3D1&access_token=xyz")
    client "/v1 -d a=x&1", http("GET /v1?a=x%261&access_token=xyz")

    client "-d b=2 /v1 -d a=1", http("GET /v1?b=2&a=1&access_token=xyz")
  end

  context "(POST)" do
    client "/v1/me -F fields=id,name", http("POST /v1/me", {"fields" => "id,name", "access_token" => "xyz"})
  end

  context "(POST: BATCH)" do
    client %(-F batch=[{"method":"GET","relative_url":"me"}]),
      http("POST /", {"batch" => %([{"method":"GET","relative_url":"me"}]), "access_token" => "xyz"})
    client %(-F batch=[{"method":"GET","relative_url":"v2.10/act_123/campaigns?fields=account_id%2Ceffective_status&effective_status=%5B%22ACTIVE%22%5D"}]),
      http("POST /", {"batch" => %([{"method":"GET","relative_url":"v2.10/act_123/campaigns?fields=account_id%2Ceffective_status&effective_status=%5B%22ACTIVE%22%5D"}]), "access_token" => "xyz"})
  end

  context "(BATCH)" do
    it "batch with block" do
      res = http_mock_listen do |port|
        uri = URI.parse("http://localhost:#{port}").to_s
        authorize = " -K #{fburlrc}"
        Facebook::Client.new(authorize.to_s + " -H #{uri}").batch do |batch|
          batch.execute("/v2.10/me")
          batch.execute("/v2.10/act_123/campaigns")
        end
      end
      res.should http("POST /", {"batch" => %([{"method":"GET","relative_url":"v2.10/me"},{"method":"GET","relative_url":"v2.10/act_123/campaigns"}]), "access_token" => "xyz"})
    end
  end

  context "(Append Args)" do
    it "Client.new(args1).execute(args2)" do
      res = http_mock_listen do |port|
        host = URI.parse("http://localhost:#{port}").to_s
        client = Facebook::Client.new("-K #{fburlrc} -H #{host} -d a=1")
        client.execute("/v1")
      end
      res.should http("GET /v1?a=1&access_token=xyz")
    end

    it "Client.new(args1).merge(args2).execute" do
      res = http_mock_listen do |port|
        host = URI.parse("http://localhost:#{port}").to_s
        client = Facebook::Client.new("-K #{fburlrc} -H #{host} -d a=1")
        client = client.merge("/v1")
        client.execute
      end
      res.should http("GET /v1?a=1&access_token=xyz")
    end
  end

  context "(error features)" do
    it "/v1/foo -d a" do
      expect_raises(Facebook::Errors::EqualNotFound) do
        http_client("/v1/foo -d a")
      end
    end    

    it "xxx" do
      expect_raises(Facebook::Errors::UnknownCommand) do
        http_client("xxx")
      end
    end

    it "-F batch=xxx" do
      expect_raises(Facebook::Errors::BatchJsonError) do
        http_client("-F batch=xxx")
      end
    end
  end

  context "(without authorization)" do
    it "raises NotAuthorized" do
      expect_raises(Facebook::Errors::NotAuthorized) do
        http_client("/me", " -K /dev/null")
      end
    end
  end
end

private def http_client(cmd, authorize = " -K #{fburlrc}")
  http_mock_listen do |port|
    host = URI.parse("http://localhost:#{port}").to_s
    Facebook::Client.new(cmd + authorize.to_s + " -H #{host}").execute
  end
end
