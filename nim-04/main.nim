import os
import parseutils
import sequtils
import strscans
import strutils

setCurrentDir(getAppDir())

type Range = tuple[start: uint, ending: uint] # end is a nim keyword, lol
type Pair = tuple[first: Range, second: Range]

proc isContained(pair: Pair): bool =
    let (a, b) = pair
    return a.start >= b.start and a.ending <= b.ending or
        b.start >= a.start and b.ending <= a.ending

proc hasOverlap(pair: Pair): bool =
    let (a, b) = pair
    return not (a.ending < b.start or a.start > b.ending)

proc parseRange(input: string, rangeVal: var Range, start: int): int =
    # unnecessary complexity because I wanted to explore the user-defined
    # matching part of scanf()
    result = 0
    # ideally we'd check the outputs of all of these and abort if they
    # returned 0
    result += parseUInt(input, rangeVal.start, start + result)
    result += skip(input, "-", start + result)
    result += parseUInt(input, rangeVal.ending, start + result)

proc parsePair(input: string): Pair =
    var first, second: Range
    if not scanf(input, "${parseRange},${parseRange}", first, second):
        quit "Error parsing range pair in line: " & input
    return (first, second)

proc first() =
    let pairs = readFile("input.txt").strip().splitLines().map(parsePair)
    let contained = pairs.countIt(it.isContained())
    echo contained

proc second() =
    let pairs = readFile("input.txt").strip().splitLines().map(parsePair)
    let overlapping = pairs.countIt(it.hasOverlap())
    echo overlapping


# first()
second()

