module Fburl
  # library should not be effected by environment like '~/.fburlrc'
  REQUEST_PREPENDED_ARGS = ["-K", "/dev/null"]

  def self.request(args : String) : Controller::RequestController
    request(args.split)
  end

  def self.request(args : Array(String)) : Controller::RequestController
    cli = CLI.new(exit_on_error: false)
    cli.setup(REQUEST_PREPENDED_ARGS + args)
    Controller::RequestController.new(cli.client, cli.opts, IO::Memory.new)
  end
end
