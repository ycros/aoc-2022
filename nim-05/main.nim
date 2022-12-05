import options
import os
import deques
import pegs
import sequtils
import strscans
import strutils

setCurrentDir(getAppDir())


type
    Stacks = seq[Deque[char]]
    ParsingState = enum psCrates, psMoves
    Move = tuple[amount: int, src: int, dst: int]

let crateGrammar = peg"""
line       <- ^(column \s)+ column$
column     <- (emptyCrate / crate)
emptyCrate <- {'   '}
crate      <- \[ {\a} \]
"""

proc parseCrateLine(line: string, stacks: var Stacks) =
    if line =~ crateGrammar:
        for i, m in matches:
            if m == "":
                break
            if i+1 > stacks.len:
                stacks.add(initDeque[char]())
            if m == "   ":
                discard
            else:
                stacks[i].addLast(m[0])
    else:
        echo "parse error: ", line

proc parseMoveLine(line: string): Move =
    if not line.scanf("move $i from $i to $i", result.amount, result.src, result.dst):
        echo "parse error: ", line

proc loadAndParse(): (seq[Move], Stacks) =
    let lines = readFile("input.txt").splitLines()

    var state = psCrates
    var stacks: Stacks
    var moves: seq[Move]

    for line in lines:
        if line == "":
            continue
        if line.startsWith(" 1"):
            state = psMoves
            continue

        case state:
        of psCrates:
            parseCrateLine(line, stacks)
        of psMoves:
            moves.add parseMoveLine(line)

    return (moves, stacks)

proc runMovesFirst(moves: seq[Move], stacks: var Stacks) =
    for move in moves:
        # The following is what I wanted to write, for better clarity...
        # But assigning these to a var copies them wholesale, and there
        # doesn't seem to be an easy way to just grab a reference to them
        #
        # var src = stacks[move.src - 1]
        # var dst = stacks[move.dst - 1]
        # for _ in 0..<move.amount:
        #     dst.addFirst(src.popFirst())

        for _ in 0..<move.amount:
            stacks[move.dst - 1].addFirst(stacks[move.src - 1].popFirst())

proc runMovesSecond(moves: seq[Move], stacks: var Stacks) =
    var temp: Deque[char]
    for move in moves:
        for _ in 0..<move.amount:
            temp.addFirst(stacks[move.src - 1].popFirst())
        for crate in temp:
            stacks[move.dst - 1].addFirst(crate)
        temp.clear()

proc first() =
    var (moves, stacks) = loadAndParse()
    runMovesFirst(moves, stacks)
    echo stacks.mapIt(it.peekFirst).join()

proc second() =
    var (moves, stacks) = loadAndParse()
    runMovesSecond(moves, stacks)
    echo stacks.mapIt(it.peekFirst).join()

# first()
second()