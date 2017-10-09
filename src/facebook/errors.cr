module Facebook::Errors
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

  define_error NotImplemented = "Not implemented yet: %s"
  define_error InvalidOption  = "Invalid option: %s"
  define_error InvalidConfig  = "Invalid config: %s"
  define_error BatchJsonError = "Batch parameter must be a JSON array: %s"
  define_error PathNotFound   = "No URI specified"
  define_error ConfigNotFound = "Config is not found: '%s'"
  define_error NotAuthorized  = "You need to authorize first."
  define_error UnknownCommand = "Unknown command: %s"
  define_error EqualNotFound  = "Data needs '=', but '%s' is given"
end
