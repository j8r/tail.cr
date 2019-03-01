require "spec"
require "../src/tail"

describe Tail do
  temp_file = __DIR__ + "/temp_file"
  output_channel = Channel(String).new
  File.touch temp_file

  describe File do
    describe "follow" do
      it "the end" do
        data = "test"
        spawn do
          Tail::File.new(temp_file).follow do |str|
            output_channel.send str
          end
        end
        sleep 0.1
        File.open temp_file, "a", &.print data
        output_channel.receive.should eq data
      end

      it "last lines and follow the end" do
        data = "test\ndata"
        spawn do
          Tail::File.new(temp_file).follow do |str|
            output_channel.send str
          end
        end
        sleep 0.1
        File.open temp_file, "a", &.print data
        output_channel.receive.should eq data
      end
    end

    it "should watch the end" do
      File.write temp_file, ""
      data = "test"
      spawn do
        Tail::File.new(temp_file).watch(lines: 0) do |str|
          output_channel.send str
        end
      end
      sleep 0.1
      File.open temp_file, "a", &.print data
      output_channel.receive.should eq data
    end

    describe "returns last lines" do
      File.write temp_file, "test\ndata"
      it "inferior to the file's size" do
        Tail::File.new(temp_file).last_lines(lines: 10).should eq ["test", "data"]
      end
      it "superior to the file's size" do
        Tail::File.new(temp_file).last_lines(lines: 1).should eq ["data"]
      end
    end
  end
  File.delete temp_file
end
