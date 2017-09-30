require "./spec_helper"

describe Fburl::CLI do
  fburl "/v1/foo -d fields=id,name" do
    opts.command!.should eq("request")
    opts.subcmds.should eq(empty_array)
    opts.path.should eq("/v1/foo")
    opts.data.should eq({"fields" => "id,name"})
  end

  context "(without commands)" do
    fburl "/v1/foo" do
      opts.command!.should eq("request")
      opts.subcmds.should eq(empty_array)
      opts.path.should eq("/v1/foo")
      opts.data.should eq(empty_hash)
    end

    fburl "/v1/foo -d a=b" do
      opts.command!.should eq("request")
      opts.subcmds.should eq(empty_array)
      opts.path.should eq("/v1/foo")
      opts.data.should eq({"a" => "b"})
    end

    fburl "-d c=d /v1/foo -d a=b" do
      opts.command!.should eq("request")
      opts.subcmds.should eq(empty_array)
      opts.path.should eq("/v1/foo")
      opts.data.should eq({"c" => "d", "a" => "b"})
    end
  end

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

  context "(explicitly specify unknown command)" do
    fburl "xxx /v1/foo" do
      opts.command.should eq("xxx")
      expect_raises(Fburl::Errors::UnknownCommand) do
        opts.command!
      end
      opts.subcmds.should eq(empty_array)
      opts.path.should eq("/v1/foo")
      opts.data.should eq(empty_hash)
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

  context "(escaping parameters)" do
    fburl "/v1/foo -d a=1:2" do
      opts.command!.should eq("request")
      opts.subcmds.should eq(empty_array)
      opts.path.should eq("/v1/foo")
      opts.data.should eq({"a" => "1:2"})
    end
  end

  context "(escaping parameters)" do
    fburl "/v1/foo -d a=1:2" do
      opts.command!.should eq("request")
      opts.subcmds.should eq(empty_array)
      opts.path.should eq("/v1/foo")
      opts.data.should eq({"a" => "1:2"})
    end
  end

  context "(error features)" do
    it "/v1/foo -d a" do
      expect_raises(Fburl::Errors::EqualNotFound) do
        mock_cli("/v1/foo -d a")
      end
    end    
  end
end
