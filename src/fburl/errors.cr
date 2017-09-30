module Fburl::Errors
  class Base < Exception
  end

  private macro define_error(assign)
    class {{assign.target.id}} < Base
      {% if assign.value.stringify.includes?("%s") %}
        def initialize(*arg)
          super({{assign.value}} % arg)
        end
      {% else %}
        def initialize(msg = nil)
          super(msg || {{assign.value}})
        end
      {% end %}        
    end
  end

  define_error InvalidConfig  = "Invalid config: %s"
  define_error PathNotFound   = "Path not found"
  define_error RcfileNotFound = "rcfile is not found: '%s'"
  define_error NotAuthorized  = "You need to authorize first."
  define_error UnknownCommand = "Unknown command: %s"
  define_error UnknownSubcmds = "Unknown subcmds: %s"
  define_error EqualNotFound  = "Post data needs '=', but '%s' is given"
end
