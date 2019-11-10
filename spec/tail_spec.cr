require "spec"
require "../src/tail"

def spec_with_tempfile(&block)
  tempfile = File.tempfile prefix: "tail-temp-file", suffix: nil
  begin
    yield tempfile
  ensure
    tempfile.delete
  end
end

describe Tail do
  output_channel = Channel(String).new

  describe File do
    describe "follow" do
      it "to the end" do
        spec_with_tempfile do |tempfile|
          data = "test"
          spawn do
            Tail::File.open tempfile.path, &.follow do |str|
              output_channel.send str
            end
          end
          sleep 0.1
          File.open tempfile.path, "a", &.print data
          output_channel.receive.should eq data
        end
      end

      it "last lines and follow the end" do
        spec_with_tempfile do |tempfile|
          data = "test\ndata"
          spawn do
            Tail::File.new(tempfile).follow do |str|
              output_channel.send str
            end
          end
          sleep 0.1
          File.open tempfile.path, "a", &.print data
          output_channel.receive.should eq data
        end
      end
    end

    it "should watch the end" do
      spec_with_tempfile do |tempfile|
        data = "test"
        spawn do
          Tail::File.new(tempfile).watch(lines: 0) do |str|
            output_channel.send str
          end
        end
        sleep 0.1
        File.open tempfile.path, "a", &.print data
        output_channel.receive.should eq data
      end
    end

    describe "returns last lines" do
      it "inferior to the file's size" do
        spec_with_tempfile do |tempfile|
          File.open tempfile.path, "a", &.print "test\ndata"
          Tail::File.new(tempfile).last_lines(lines: 10).should eq ["test", "data"]
        end
      end
      it "superior to the file's size" do
        spec_with_tempfile do |tempfile|
          File.open tempfile.path, "a", &.print "test\ndata"
          Tail::File.new(tempfile).last_lines(lines: 1).should eq ["data"]
        end
      end
    end
  end
end
