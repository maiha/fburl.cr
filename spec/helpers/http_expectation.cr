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
      raise "method should be '%s', but got '%s'" % [value.method, method]
    end

    if resource != value.resource
      raise "path should be '%s', but got '%s'" % [value.resource, resource]
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
