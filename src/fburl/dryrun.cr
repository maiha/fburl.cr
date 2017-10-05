module Fburl
  # library should not be effected by environment like '~/.fburlrc'
  DRYRUN_PREPENDED_ARGS = ["-K", "/dev/null"]

  def self.dryrun(args : String) : Controller::DryrunController
    dryrun(args.split)
  end

  def self.dryrun(args : Array(String)) : Controller::DryrunController
    cli = CLI.new(exit_on_error: false)
    cli.setup(DRYRUN_PREPENDED_ARGS + args)
    Controller::DryrunController.new(cli.client, cli.opts, IO::Memory.new)
  end
end
