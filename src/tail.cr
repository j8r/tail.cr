module Tail
  # Follows the new appended bytes of an `IO`
  def self.follow(io : IO, delay = 0.1, &block)
    loop do
      content = io.gets_to_end
      yield content if !content.empty?
      sleep delay
    end
  end

  struct File
    getter file : ::File

    def initialize(@file : ::File)
    end

    def initialize(file : String)
      @file = ::File.new file
    end

    # Get the last n `lines`.
    # `line_size` is used to extract the end of the file to calculate the trailing lines
    def last_lines(lines = 10, line_size = 1024) : Array(String)
      # Assuming each line is sizing at least line_size
      if (size = @file.size) > 0
        offset = lines * line_size
        @file.seek 0 - (size < offset ? size : offset), IO::Seek::End
        end_lines = @file.gets_to_end.lines
        if end_lines.size > lines
          end_lines[end_lines.size - lines..-1]
        else
          end_lines
        end
      else
        Array(String).new
      end
    end

    # Follow the end of a file
    def follow(lines = 0, line_size = 1024, delay = 0.1, &block)
      if lines > 0
        if end_lines = last_lines(lines, line_size)
          yield end_lines.join '\n'
        end
      else
        @file.skip_to_end
      end
      Tail.follow(@file, delay) { |str| yield str }
    end
  end
end
