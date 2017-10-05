require "./spec_helper"

describe Fburl::CLI do
  describe "detect rcfile" do
    context "(with -K)" do
      it "should detect it if exist" do
        cli = Fburl::CLI.new
        cli.setup("-K /dev/null")
        cli.try_rc.map(&.path).get?.should eq("/dev/null")
      end

      it "should not detect if not exist" do
        cli = Fburl::CLI.new
        cli.setup("-K /no-such-file-xxx")
        cli.try_rc.map(&.path).get?.should eq(nil)
      end
    end

    context "(double -K)" do
      it "should detect latter one" do
        cli = Fburl::CLI.new
        cli.setup("-K /no-such-file-xxx /v2.5/me -K /dev/null")
        cli.try_rc.map(&.path).get?.should eq("/dev/null")
      end
    end
  end
end
