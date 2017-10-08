require "./spec_helper"

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

private def cli(arg : String, expect : Spec::HttpExpectation)
  it arg do
    req = http_cli(arg)
    req.should expect
  end
end

module Spec
  record HttpRequest,
    method : String,
    resource : String,
    form_data : Hash(String, String)

  def HttpRequest.parse(value : String, form : Hash(String, String)? = nil)
    form ||= Hash(String, String).new
    method, path = value.split(/\s+/, 2)
    new(method, path, form)
  end
  
  struct HttpExpectation
    def initialize(@expected_value : HttpRequest)
    end

    def match(actual_value)
      # raise here to desribe errors because body(io) can be read only once.
      actual_value.expect!(@expected_value)
      true
    end

    def failure_message(actual_value)
      actual_value.expect!(@expected_value)
      "BUG: Expected: #{actual_value.class}\n should failure, but succeeded!"
    rescue err
      "Expected: #{actual_value.class}\nto %s" % err
    end

    def negative_failure_message(actual_value)
      "Expected: value #{actual_value.inspect}\n to not match: #{@expected_value.inspect}"
    end
  end

  module Expectations
    def http(value : String, form : Hash(String, String)? = nil)
      HttpExpectation.new(HttpRequest.parse(value, form))
    end
  end
end

class HTTP::Request
  def expect!(value : Spec::HttpRequest)
    if method != value.method
      raise "method should be '%s', but got '%s'" % [method, value.method]
    end

    if resource != value.resource
      raise "path should be '%s', but got '%s'" % [resource, value.resource]
    end

    if form_data?
      got = form_data
      exp = value.form_data
      if got.keys.sort != exp.keys.sort
        raise "form should have '%s', but got '%s'" % [exp.keys.inspect, got.keys.inspect]
      end

      got.each do |k, v|
        if v != exp[k]
          raise "form[%s] should be '%s', but got '%s'" % [k, exp[k], v]
        end
      end
    end
  end
end
