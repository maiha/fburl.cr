require "./spec_helper"

private def extract(argv) : String
  Fburl::CLI.parse_command(argv)
end

describe Fburl::CLI do
  describe ".parse_command" do
    context "()" do
      it "should return 'request'" do
        extract([] of String).should eq("request")
      end
    end

    context "([config])" do
      it "should return 'config'" do
        extract(["config"]).should eq("config")
      end
    end

    context "([config, show])" do
      it "should return 'config'" do
        extract(["config", "show"]).should eq("config")
      end
    end

    context "(alias with options)" do
      it "should return 'alias'" do
        extract("alias me /v2.5/me -K #{fburlrc}".split).should eq("alias")
      end
    end

    context "(with invalid command xxx)" do
      it "should return 'xxx' without exceptions" do
        extract("xxx".split).should eq("xxx")
      end
    end
  end
end
