require "./spec_helper"

describe "fburl alias" do
  describe "spec functions itself" do
    fburl "works", {"h" => "/help"}  do
      path = tmp_file "fburlrc"
      File.read(path).should eq <<-EOF
        [alias]
        h = "/help"

        EOF
    end

    fburl "works", {"h" => "/help", "a" => "x y z"}  do
      path = tmp_file "fburlrc"
      expected = <<-EOF
        [alias]
        h = "/help"
        a = "x y z"

        EOF
    end
  end

  describe "apply" do
    context "(alias found)" do
      fburl "h", {"h" => "/help"}  do
        opts.command.should eq("request")
        opts.subcmds.should eq(empty_array)
        opts.path.should eq("/help")
        opts.data.should eq(empty_hash)
      end
    end

    context "(alias with data)" do
      fburl "h", {"h" => "/help -d a=b"} do
        opts.command.should eq("request")
        opts.subcmds.should eq(empty_array)
        opts.path.should eq("/help")
        opts.data.should eq({"a" => "b"})
      end
    end

    context "(alias with merged data)" do
      fburl "h -d x=y", {"h" => "/help -d a=b"} do
        opts.command.should eq("request")
        opts.subcmds.should eq(empty_array)
        opts.path.should eq("/help")
        opts.data.should eq({"a" => "b", "x" => "y"})
      end
    end

    context "(alias without path)" do
      fburl "ab /foo -d x=y", {"ab" => "-d a=b"} do
        opts.command.should eq("request")
        opts.subcmds.should eq(empty_array)
        opts.path.should eq("/foo")
        opts.data.should eq({"a" => "b", "x" => "y"})
      end
    end
  end
end
