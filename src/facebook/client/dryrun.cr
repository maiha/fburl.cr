class Facebook::Client
  class Dryrun
    @options : Options

    def initialize(options)
      @options = options.dup
      @options.authorize!
      @lines = Array(String).new

      build_head
      build_data
      build_form
      build_path
    end

    def build(delimiter : String = " ")
      @lines.join(delimiter)
    end

    def to_s(io : IO)
      io << build
    end

    private def build_head
      @lines << String.build do |io|
        io << "curl -s "
        if @options.method.get?
          io << "-G"
        else
          io << "-X %s" % @options.method.to_s
        end
      end
    end

    private def build_data
      @options.data.each do |key, val|
        @lines << "-d '%s=%s'" % [key, val]
      end
    end

    private def build_form
      @options.form.each do |key, val|
        @lines << "-F '%s=%s'" % [key, val]
      end
    end

    private def build_path
      @lines << "%s%s" % [@options.base_url, @options.path]
    end
  end

  def dryrun(arg : String? = nil)
    Dryrun.new(merge(arg).options)
  end
end
