import math
import os
import sequtils
import sets
import strutils
import terminal

setCurrentDir(getAppDir())


type
    Pos = tuple[x: int, y: int]
    Height = range[0..9]
    Trees = seq[seq[Height]]
    Direction = enum dnUp, dnDown, dnLeft, dnRight


proc load(): Trees =
    let input = readFile("input.txt").strip().splitLines()
    let size = input.len # it's a square

    for i in 0..<size:
        result.add(newSeq[Height](size))

    for y, line in input:
        for x, c in line:
            let height = int(c) - int('0')
            result[y][x] = height


template outerIter(direction: Direction, statements: untyped) =
    when direction == dnUp or direction == dnDown:
        for x {.inject.} in 0..<trees.len-1:
            statements
    else:
        for y {.inject.} in 0..<trees.len-1:
            statements

template innerIter(direction: Direction, statements: untyped) =
    when direction == dnUp or direction == dnDown:
        when direction == dnUp:
            for y {.inject.} in countdown(trees.len-1, 1):
                let innerIdx {.inject.} = (trees.len-1) - y
                statements
        else:
            for y {.inject.} in 0..<trees.len-1:
                let innerIdx {.inject.} = y
                statements
    else:
        when direction == dnLeft:
            for x {.inject.} in countdown(trees.len-1, 1):
                let innerIdx {.inject.} = (trees.len-1) - x
                statements
        else:
            for x {.inject.} in 0..<trees.len-1:
                let innerIdx {.inject.} = x
                statements


template findHidden(trees: Trees, hiddenSet: var HashSet[Pos], direction: Direction) =
    outerIter(direction):
        var highest = -1
        innerIter(direction):
            let height = trees[y][x]
            if height <= highest:
                hiddenSet.incl((x, y))
            else:
                highest = height


proc first() =
    let trees = load()

    var rightHidden: HashSet[Pos]
    var leftHidden: HashSet[Pos]
    var downHidden: HashSet[Pos]
    var upHidden: HashSet[Pos]
    findHidden(trees, rightHidden, dnRight)
    findHidden(trees, leftHidden, dnLeft)
    findHidden(trees, upHidden, dnUp)
    findHidden(trees, downHidden, dnDown)

    let allHidden = rightHidden * leftHidden * downHidden * upHidden

    for y, row in trees:
        for x, height in row:
            if (x, y) in allHidden:
                stdout.styledWrite(fgCyan, $height)
            else:
                stdout.styledWrite(fgGreen, $height)
        echo ""
    echo ""

    echo allHidden.len
    echo (trees.len ^ 2) - allHidden.len


template calcScenicScore(trees: Trees, direction: Direction): seq[seq[int]] =
    block: # use block: here so we can "return" a value
        # we may iterate in any order, pre-allocate the result so we can just index into it
        var result: seq[seq[int]]
        for i in 0..<trees.len:
            result.add(newSeq[int](trees.len))

        outerIter(direction):
            var lastHeights: array[Height, int]
            innerIter(direction):
                let height = trees[y][x]
                let nearestBlockerDistance = (height..high(Height)).mapIt(lastHeights[it]).foldl(max(a, b), 0)
                let distance = innerIdx - nearestBlockerDistance
                result[y][x] = distance
                lastHeights[height] = innerIdx

        result


proc second() =
    var trees = load()

    let rightScores = calcScenicScore(trees, dnRight)
    let leftScores = calcScenicScore(trees, dnLeft)
    let upScores = calcScenicScore(trees, dnUp)
    let downScores = calcScenicScore(trees, dnDown)

    var allScores: seq[seq[int]]

    for y in 0..<trees.len:
        allScores.add(@[])
        for x in 0..<trees.len:
            allScores[y].add(rightScores[y][x] * leftScores[y][x] * upScores[y][x] * downScores[y][x])

    var highestScore = 0
    for row in allScores:
        for score in row:
            highestScore = max(highestScore, score)
    echo highestScore


# first()
second()
