import unittest
import toposort
import std/tables

test "circular dependency in table":
  let sampleTable = toTable {
    'a': @['b', 'c', 'd', 'f'],
    'b': @['c'],
    'c': @['e', 'f'],
    'd': @['c'],
    'e': @[],
    'f': @['d']
  }

  expect ValueError:
    discard topoSort(sampleTable)

test "missing dependency in table":
  let sampleTable = toTable {
    'a': @['b', 'c', 'd', 'f'],
    'b': @['c'],
    'c': @['e', 'f'],
    'd': @['c'],
    'e': @['g'],
    'f': @[]
  }

  expect ValueError:
    discard topoSort(sampleTable)

test "circular dependency in array":
  let sampleTable = [
    ('a', @['b', 'c', 'd', 'f']),
    ('b', @['c']),
    ('c', @['e', 'f']),
    ('d', @['c']),
    ('e', @[]),
    ('f', @['d'])
  ]

  expect ValueError:
    discard topoSort(sampleTable)

test "missing dependency in array":
  let sampleTable = [
    ('a', @['b', 'c', 'd', 'f']),
    ('b', @['c']),
    ('c', @['e', 'f']),
    ('d', @['c']),
    ('e', @['g']),
    ('f', @[])
  ]

  expect ValueError:
    discard topoSort(sampleTable)


