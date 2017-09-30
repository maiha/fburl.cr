require "../spec_helper"

describe Fburl::Controller::RequestController do
  describe "#dryrun" do
    context "(with valid access_token)" do
      it "should print curl command" do
        stdout = String.build do |io|
          cli = Fburl::CLI.new(output: io, exit_on_error: false)
          cli.run(["-a", "abc", "/foo", "-n"])
        end
        stdout.should eq <<-EOF
          curl -G \\
               -d 'access_token=abc' \\
               https://graph.facebook.com/foo

          EOF
      end
    end
  end
end
