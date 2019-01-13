# Tail

Tailing library for Crystal - get and/or follow the end of a file/IO

[Inotify.cr](https://github.com/petoem/inotify.cr) is used in Linux

## Installation

Add the dependency to your `shard.yml`:

```yaml
dependencies:
  exec:
    github: j8r/tail
```

## Usage

### `Tail`

`.follow(io : IO, delay = 0.1, &block)`

Follows the new appended bytes of an `IO`

### `Tail::File`

#### Constructors
`.new(@file : ::File)`

`.new(file : String)` 

#### Instance Method

`#last_lines(lines = 10, line_size = 1024) : Array(String)`

Get the last n `lines`.

`line_size` is used to extract the end of the file, and then calculate the trailing lines

`#follow(lines = 0, line_size = 1024, delay = 0.1, &block : String -> _)`

Follow the end of a file

`#watch(lines = 0, line_size = 1024, &block : String -> _)`

(Linux Only) Use Inotify to yield newly added bytes from the file

## Examples

```crystal
require "tail"

Tail::File.new("file").follow do |str|
  print str
end

Tail::File.new("file").last_lines
```

## License                                                                                                 

Copyright (c) 2018 Julien Reichardt - ISC License
