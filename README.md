`toposort` is a topological sorting algorithm for Nim.

# Features

- Highly efficient sorting using hashes and Kahn's algorithm
- Hash collision detection with detailed error messages
- Missing dependency detection with detailed error messages
- Circular dependency detection

# Usage

This package provides an iterator/proc named `topoSort`. Here are all its
declarations:

```nim
iterator topoSort*[T: Hashable](graph: Table[T, HashableCollection[T]]): T
iterator topoSort*[T: Hashable](graph: openArray[(T, HashableCollection[T])]): T

proc topoSort*[T: Hashable](graph: Table[T, HashableCollection[T]]): seq[T]
proc topoSort*[T: Hashable](graph: openArray[(T, HashableCollection[T])]): seq[T]
```

`topoSort` performs a topological sort of a collection of items that have type
`T`. The input to `topoSort` is a map of items to their dependencies. The items
must implement the concept `Hashable`, which has two requirements:

  - `hash(T): Hash` (a function that returns a hash of `T`)
  - `` `$`(T): string`` (a `$` operator that returns a `string`). This
    requirement can be removed by adding `-d:topoHashableNoStringify` to the
    command line.

When used as an iterator, `topoSort` yields the items in topological order.
When used as a proc, it returns a seq of the items in topological order.

# Example

```nim
import toposort
import std/[uri, tables]

let
  google = parseUri("https://google.com")
  unpkg = parseUri("https://unpkg.com")
  nytimes = parseUri("https://nytimes.com")
  aws = parseUri("https://amazonaws.com")
  amazon = parseUri("https://amazon.com")

let uriTable = toTable {
  google: @[unpkg],
  nytimes: @[unpkg, google, amazon],
  amazon: @[aws, google],
  aws: @[unpkg],
  unpkg: @[]
}

for item in topoSort(uriTable):
  echo item

let charTable = toTable {
  'a': @['b', 'c', 'd', 'f'],
  'b': @['c'],
  'c': @['e', 'f'],
  'd': @['c'],
  'e': @['f'],
  'f': @[]
}

for item in topoSort(charTable):
  echo item

let intPairs = [
  (1, @[2, 3, 4]),
  (2, @[4]),
  (3, @[2, 6]),
  (4, @[5]),
  (5, @[6]),
  (6, @[])
]

for item in topoSort(intPairs):
  echo item
```

# Benchmarking

`tests/benchmark.nim` contains a (nearly-) complete dependency tree for Python
3.8, generated from apt on Ubuntu 20.03.4 LTS for WSL. Circular dependencies
were removed by hand. With over 11,000 individual nodes in the dependency
graph, this is a pretty good way to benchmark the algorithm.

The `benchmark.ps1` PowerShell script is provided to aid in running the
benchmark.

# Performance

If you are trying to do a topological sort on a very large input data set (like
the one in `tests/benchmark.nim`), you may find that `topoSort` runs slowly.
Compiling with optimizations enabled (`-d:release --opt:speed`) will make
it run substantially faster - on my machine, the benchmark runs about 3.5x
faster with `-d:release --opt:speed` flags added.
