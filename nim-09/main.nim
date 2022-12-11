import math
import os
import sets
import strscans
import strutils
import sequtils

setCurrentDir(getAppDir())

type
    Direction = enum dnUp, dnDown, dnLeft, dnRight
    Move = tuple[dir: Direction, amount: int]
    Pos = tuple[x: int, y: int]

proc parseDir(rawDir: char): Direction =
    case rawDir
    of 'U': return dnUp
    of 'D': return dnDown
    of 'L': return dnLeft
    of 'R': return dnRight
    else:
        quit "Tried to parse invalid dir: " & rawDir

proc loadMoves(): seq[Move] =
    let lines = readFile("input.txt").strip().splitLines()
    for line in lines:
        var direction: char
        var amount: int
        if line.scanf("$c $i", direction, amount):
            result.add((parseDir(direction), amount))

proc follow(leader: Pos, follower: var Pos) =
    let xDelta = leader.x - follower.x
    let yDelta = leader.y - follower.y

    if abs(xDelta) <= 1 and abs(yDelta) <= 1:
        return

    if xDelta > 0:
        follower.x.inc
    elif xDelta < 0:
        follower.x.dec
    if yDelta > 0:
        follower.y.inc
    elif yDelta < 0:
        follower.y.dec


proc first() =
    let moves = loadMoves()

    var headPos: Pos
    var tailPos: Pos
    var visited: HashSet[Pos]

    visited.incl(tailPos)

    for (dir, amount) in moves:
        for step in 0..<amount:
            case dir:
            of dnDown: headPos.y.inc()
            of dnUp: headPos.y.dec()
            of dnLeft: headPos.x.dec()
            of dnRight: headPos.x.inc()

            follow(headPos, tailPos)

            visited.incl(tailPos)
            # echo "H:", headPos, " T:", tailPos

    echo visited.len


proc render(segmentPos: openArray[Pos]) =
    var xmax: int = 5
    var xmin: int = -5
    var ymax: int = 5
    var ymin: int = -5
    for (x, y) in segmentPos:
        xmax = max(xmax, x)
        xmin = min(xmin, x)
        ymax = max(ymax, y)
        ymin = min(ymin, y)

    echo "---"
    for y in ymin..ymax:
        for x in xmin..xmax:
            block pickChar:
                for i, (sx, sy) in segmentPos:
                    if sx == x and sy == y:
                        stdout.write(if i > 0: $i else: "H")
                        break pickChar
                stdout.write(".")
        stdout.write("\n")
    stdout.flushFile()


proc second() =
    let moves = loadMoves()

    var segmentPos: array[10, Pos]
    var visited: HashSet[Pos]

    visited.incl((0, 0))

    # render(segmentPos, visited)

    for (headDir, amount) in moves:
        for step in 0..<amount:
            case headDir:
            of dnDown: segmentPos[0].y.inc()
            of dnUp: segmentPos[0].y.dec()
            of dnLeft: segmentPos[0].x.dec()
            of dnRight: segmentPos[0].x.inc()
            for i in 1..<segmentPos.len:
                follow(segmentPos[i-1], segmentPos[i])
                if i == segmentPos.len - 1:
                    visited.incl(segmentPos[i])
            # render(segmentPos, visited)

    echo visited.len
    # render(segmentPos, visited)


# first()
second()
