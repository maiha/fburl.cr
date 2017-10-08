require "./spec_helper"

describe Fburl::CLI do
  context "(explicitly specify command)" do
    fburl "request /v1/foo" do
      opts.command!.should eq("request")
      opts.subcmds.should eq(empty_array)
      opts.path.should eq("/v1/foo")
      opts.data.should eq(empty_hash)
    end

    fburl "request /v1/foo -d a=b" do
      opts.command!.should eq("request")
      opts.subcmds.should eq(empty_array)
      opts.path.should eq("/v1/foo")
      opts.data.should eq({"a" => "b"})
    end

    fburl "request -d c=d /v1/foo -d a=b" do
      opts.command!.should eq("request")
      opts.subcmds.should eq(empty_array)
      opts.path.should eq("/v1/foo")
      opts.data.should eq({"c" => "d", "a" => "b"})
    end
  end

  context "(subcmds)" do
    fburl "alias h /v1/foo" do
      opts.command!.should eq("alias")
      opts.subcmds.should eq(["h"])
      opts.path.should eq("/v1/foo")
      opts.data.should eq(empty_hash)
    end

    fburl "alias h /v1/foo -d a=b" do
      opts.command!.should eq("alias")
      opts.subcmds.should eq(["h"])
      opts.path.should eq("/v1/foo")
      opts.data.should eq({"a" => "b"})
    end
  end
end
