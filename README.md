# Tail

[![Build Status](https://cloud.drone.io/api/badges/j8r/tail.cr/status.svg)](https://cloud.drone.io/j8r/tail.cr)
[![ISC](https://img.shields.io/badge/License-ISC-blue.svg?style=flat-square)](https://en.wikipedia.org/wiki/ISC_license)

Tailing library for Crystal - get and/or follow the end of a file/IO

[Inotify.cr](https://github.com/petoem/inotify.cr) library is used to watch files.

## Installation

Add the dependency to your `shard.yml`:

```yaml
dependencies:
  exec:
    github: j8r/tail
```

## Documentation

https://j8r.github.io/tail.cr

## Examples

```crystal
require "tail"

Tail::File.open "file", &.follow do |str|
  print str
end

Tail::File.open "file", &.last_lines
```

## License                                                                                                 

Copyright (c) 2018-2019 Julien Reichardt - ISC License
