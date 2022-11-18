import unittest
import toposort
import std/[tables, uri]

test "char table":
  let sampleTable = toTable {
    'a': @['b', 'c', 'd', 'f'],
    'b': @['c'],
    'c': @['e', 'f'],
    'd': @['c'],
    'e': @['f'],
    'f': @[]
  }

  let sorted = topoSort(sampleTable)

  check:
    sorted.find('a') >= 0
    sorted.find('b') >= 0
    sorted.find('c') >= 0
    sorted.find('d') >= 0
    sorted.find('e') >= 0
    sorted.find('f') >= 0

    sorted.find('a') > sorted.find('b')
    sorted.find('a') > sorted.find('c')
    sorted.find('a') > sorted.find('d')
    sorted.find('a') > sorted.find('f')

    sorted.find('b') > sorted.find('c')

    sorted.find('c') > sorted.find('e')
    sorted.find('c') > sorted.find('f')

    sorted.find('d') > sorted.find('c')

    sorted.find('e') > sorted.find('f')


test "uri table":
  let
    google = parseUri("https://google.com")
    unpkg = parseUri("https://unpkg.com")
    nytimes = parseUri("https://nytimes.com")
    aws = parseUri("https://amazonaws.com")
    amazon = parseUri("https://amazon.com")

  let sampleTable = toTable {
    google: @[unpkg],
    nytimes: @[unpkg, google, amazon],
    amazon: @[aws, google],
    aws: @[unpkg],
    unpkg: @[]
  }

  let sorted = topoSort(sampleTable)

  check:
    sorted.find(google) >= 0
    sorted.find(unpkg) >= 0
    sorted.find(nytimes) >= 0
    sorted.find(aws) >= 0
    sorted.find(amazon) >= 0

    sorted.find(google) >= sorted.find(unpkg)

    sorted.find(nytimes) >= sorted.find(unpkg)
    sorted.find(nytimes) >= sorted.find(google)
    sorted.find(nytimes) >= sorted.find(amazon)

    sorted.find(aws) >= sorted.find(unpkg)

    sorted.find(amazon) >= sorted.find(aws)
    sorted.find(amazon) >= sorted.find(google)

test "integer pairs":
  let sampleInput = [
    (1, @[2, 3, 4]),
    (2, @[4]),
    (3, @[2, 6]),
    (4, @[5]),
    (5, @[6]),
    (6, @[])
  ]

  let sorted = topoSort(sampleInput)

  check:
    sorted.find(1) >= 0
    sorted.find(2) >= 0
    sorted.find(3) >= 0
    sorted.find(4) >= 0
    sorted.find(5) >= 0
    sorted.find(6) >= 0

    sorted.find(1) > sorted.find(2)
    sorted.find(1) > sorted.find(3)
    sorted.find(1) > sorted.find(4)

    sorted.find(2) > sorted.find(4)

    sorted.find(3) > sorted.find(2)
    sorted.find(3) > sorted.find(6)

    sorted.find(4) > sorted.find(5)

    sorted.find(5) > sorted.find(6)
