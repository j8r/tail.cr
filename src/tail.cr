require "inotify"

module Tail
  # Follows the new appended bytes of an `IO`
  def self.follow(io : IO, delay = 0.1, &block)
    loop do
      if !(content = io.gets_to_end).empty?
        yield content
      end
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
    # `line_size` is used to extract the end of the file, and then calculate the trailing lines
    def last_lines(lines = 10, line_size = 1024) : Array(String)
      # Assuming each line is sizing at most line_size
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

    private def yield_last_lines(lines, line_size, &block : String -> _)
      if lines <= 0
        @file.skip_to_end
      elsif end_lines = last_lines(lines, line_size)
        yield end_lines.join '\n'
      end
    end

    # Follow the end of a file
    def follow(lines = 0, line_size = 1024, delay = 0.1, &block : String -> _)
      yield_last_lines lines, line_size, &block
      loop do
        if !(content = @file.gets_to_end).empty?
          yield content
        end
        sleep delay
      end
    end

    {% if flag?(:linux) %}
    # Use Inotify to yield newly added bytes from the file
    def watch(lines = 0, line_size = 1024, &block : String -> _)
      yield_last_lines lines, line_size, &block
      Inotify.watch(@file.path) do
        if !(content = @file.gets_to_end).empty?
          block.call content
        end
      end
    end
    {% end %}
  end
end
