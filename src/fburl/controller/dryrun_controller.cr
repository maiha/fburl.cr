class Fburl::Controller::DryrunController < Fburl::Controller::Base
  val authorize = true
  val subcmds   = false

  def dispatch
    @output.puts curl_string
  end

  def curl_string
    lf = "\\\n     "
    String.build do |io|
      io << "curl -s "
      if options.method.get?
        io << "-G "
      else
        io << "-X %s " % options.method.to_s
      end
      io << lf

      # data
      options.data.each do |key, val|
        io << "-d '%s=%s' " % [key, val]
        io << lf
      end

      # form
      options.form.each do |key, val|
        io << "-F '%s=%s' " % [key, val]
        io << lf
      end
      io << "%s%s" % [options.base_url, options.path]
    end    
  end

  Registry["dryrun"] = self
end
