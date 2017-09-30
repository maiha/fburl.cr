module Fburl::Controller::Registry
  extend self

  delegate keys, "[]", "[]=", to: controllers
  
  def controllers
    @@controllers ||= Hash(String, Base.class).new
  end
end
