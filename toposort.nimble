# Package

version       = "1.0.0"
author        = "Evan Perry Grove"
description   = "Efficient, dependency-free topological sort"
license       = "BSD-3-Clause"
srcDir        = "src"


# Dependencies

requires "nim >= 1.6.0"

task docgen, "Generate docs":
  exec "nim doc --project --index:on --outdir:htmldocs ./src/toposort"

task docserv, "Serve docs":
  exec "python -m http.server 8888 --directory htmldocs"
