require "spec"
require "../src/tail"

describe Tail do
  temp_file = __DIR__ + "/temp_file"
  File.touch temp_file
  describe File do
    it "should follow the end" do
      spawn do
        File.open temp_file, "a", &.print "test"
      end
      Tail::File.new(temp_file).follow do |str|
        str.should eq "test"
        break
      end
    end
    it "should get last lines and follow the end" do
      File.write temp_file, "test\ndata"
      Tail::File.new(temp_file).follow(lines: 2) do |str|
        str.should eq "test\ndata"
        break
      end
    end
    it "returns last lines" do
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
