## Efficient topological sorting using Kahn's algorithm.

import std/[hashes, tables, strformat]

type
  Hashable* = concept x ##\
    ## A concept for any item that can be sorted by `topoSort`. This concept \
    ## will match many common Nim types without any extra work:
    ##  - `int`
    ##  - `string`
    ##  - `Uri`
    ##  - `JsonNode`
    ##  - ...and many others.
    hash(x) is Hash
    when not defined(topoHashableNoStringify):
      ($x) is string

  HashableCollection*[T: Hashable] = concept x ##\
    ## A collection of `Hashable` items. This concept will match many common \
    ## Nim collections without any extra work, including `seq` and `array`.
    for y in x.items:
      y is T


iterator topoSortInner[T: Hashable](
    starts: var seq[(T, Hash)],
    depTree: var Table[Hash, (T, seq[Hash])],
    missingDepChecked: bool
  ): T =

  while starts.len() > 0:
    let (val, h) = starts[0]
    starts.del 0
    yield val

    var toDelete: seq[Hash]
    for k, (val, deps) in depTree.mpairs:
      let i = deps.find(h)
      if i >= 0:
        deps.del i
      if deps.len() == 0:
        starts.add (val, k)
        toDelete.add k

    for k in toDelete:
      depTree.del k

  if depTree.len() != 0:
    if missingDepChecked:
      raise ValueError.newException("Circular dependency detected")
    else:
      raise ValueError.newException("Circular or missing dependency detected")


proc validateHashCollisions[T](k: T, h: Hash, starts: seq[(T, Hash)], depTree: Table[Hash, (T, seq[Hash])]) {.inline.} =
  if depTree.hasKey(h):
    when defined(topoHashableNoStringify):
      raise ValueError.newException(fmt"Hash collision detected")
    else:
      let k2 = depTree[h][0]
      raise ValueError.newException(fmt"Hash collision between {$k} and {$k2}")
  for (k2, h2) in starts:
    if h2 == h:
      when defined(topoHashableNoStringify):
        raise ValueError.newException(fmt"Hash collision detected")
      else:
        raise ValueError.newException(fmt"Hash collision between {$k} and {$k2}")

iterator topoSort*[T: Hashable](graph: Table[T, HashableCollection[T]]): T =
  ## Perform a topological sort over a Table of items-dependency pairs.
  runnableExamples:
    import std/tables
    let dependencies = toTable {
      'a': @['b', 'c', 'd', 'f'],   # 'a' depends on 'b', 'c', 'd', and 'f'
      'b': @['c'],                  # 'b' depends on 'c'
      'c': @['e', 'f'],             # etc...
      'd': @['c'],
      'e': @['f'],
      'f': @[]
    }

    for item in topoSort(dependencies):
      echo item
  ## 
  var
    starts: seq[(T, Hash)]
    depTree: Table[Hash, (T, seq[Hash])]

  for k, deps in graph.pairs:
    let h = hash(k)

    validateHashCollisions(k, h, starts, depTree)

    var depHashes: seq[Hash]
    for dep in deps:
      if not graph.hasKey(dep):
        when defined(topoHashableNoStringify):
          raise ValueError.newException(fmt"Missing dependency")
        else:
          raise ValueError.newException(fmt"Item {$k} has missing dependency: {$dep}")
      depHashes.add hash(dep)

    if depHashes.len() == 0:
      starts.add (k, h)
    else:
      depTree[h] = (k, depHashes)

  for item in topoSortInner(starts, depTree, true):
    yield item


iterator topoSort*[T: Hashable](graph: openArray[(T, HashableCollection[T])]): T =
  ## Perform a topological sort over an openArray of item-dependency pairs.
  runnableExamples:
    let dependencies = [
      ('a', @['b', 'c', 'd', 'f']),   # 'a' depends on 'b', 'c', 'd', and 'f'
      ('b', @['c']),                  # 'b' depends on 'c'
      ('c', @['e', 'f']),             # etc...
      ('d', @['c']),
      ('e', @['f']),
      ('f', @[])
    ]

    for item in topoSort(dependencies):
      echo item
  ## 
  var
    starts: seq[(T, Hash)]
    depTree: Table[Hash,(T, seq[Hash])]

  for (k, deps) in graph:
    let h = hash(k)

    validateHashCollisions(k, h, starts, depTree)

    var depHashes: seq[Hash]
    for dep in deps:
      depHashes.add hash(dep)

    if depHashes.len() == 0:
      starts.add (k, h)
    else:
      depTree[h] = (k, depHashes)

  for item in topoSortInner(starts, depTree, false):
    yield item

proc topoSort*[T: Hashable](graph: Table[T, HashableCollection[T]]): seq[T] =
  ## Perform a topological sort over a Table of items-dependency pairs.
  runnableExamples:
    import std/tables
    let dependencies = toTable {
      'a': @['b', 'c', 'd', 'f'],   # 'a' depends on 'b', 'c', 'd', and 'f'
      'b': @['c'],                  # 'b' depends on 'c'
      'c': @['e', 'f'],             # etc...
      'd': @['c'],
      'e': @['f'],
      'f': @[]
    }

    let sorted = topoSort(dependencies)
  ## 
  for c in topoSort(graph):
    result.add c

proc topoSort*[T: Hashable](graph: openArray[(T, HashableCollection[T])]): seq[T] =
  ## Perform a topological sort over an openArray of item-dependency pairs.
  runnableExamples:
    let dependencies = [
      ('a', @['b', 'c', 'd', 'f']),   # 'a' depends on 'b', 'c', 'd', and 'f'
      ('b', @['c']),                  # 'b' depends on 'c'
      ('c', @['e', 'f']),             # etc...
      ('d', @['c']),
      ('e', @['f']),
      ('f', @[])
    ]

    let sorted = topoSort(dependencies)
  ## 
  for c in topoSort(graph):
    result.add c
