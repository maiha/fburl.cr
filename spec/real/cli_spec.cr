require "./spec_helper"

private def cli(arg : String, expect : Spec::HttpExpectation)
  it arg do
    http_cli(arg).should expect
  end
end

describe "(in http server)" do
  prepare_rcfile access_token: "xyz"

  context "(GET)" do
    cli "/v1"         , http("GET /v1?access_token=xyz")
    cli "/v1 -d a=1"  , http("GET /v1?a=1&access_token=xyz")
    cli "/v1 -d a=1:2", http("GET /v1?a=1%3A2&access_token=xyz")

    cli "-d b=2 /v1 -d a=1", http("GET /v1?b=2&a=1&access_token=xyz")
  end

  context "(POST)" do
    cli "/v1/me -F fields=id,name", http("POST /v1/me", {"fields" => "id,name", "access_token" => "xyz"})
  end

  context "(BATCH)" do
    cli %(-F batch=[{"method":"GET","relative_url":"me"}]), http("POST /", {"batch" => %([{"method":"GET","relative_url":"me"}]), "access_token" => "xyz"})
  end

  context "(error features)" do
    it "/v1/foo -d a" do
      expect_raises(Fburl::Errors::EqualNotFound) do
        http_cli("/v1/foo -d a")
      end
    end    

    it "xxx" do
      expect_raises(Fburl::Errors::UnknownCommand) do
        http_cli("xxx")
      end
    end

    it "-F batch=xxx" do
      expect_raises(Fburl::Errors::BatchJsonError) do
        http_cli("-F batch=xxx")
      end
    end
  end

  context "(without authorization)" do
    it "raises NotAuthorized" do
      expect_raises(Fburl::Errors::NotAuthorized) do
        http_cli("/me", " -K /dev/null")
      end
    end
  end
end

private def http_cli(cmd, authorize = " -K #{fburlrc}")
  http_mock_listen do |port|
    host = URI.parse("http://localhost:#{port}").to_s
    cli = Fburl::CLI.new(exit_on_error: false)
    cli.setup(cmd + authorize.to_s + " -H #{host}")
    cli.request!.execute
  end
end

