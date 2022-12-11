import std/enumerate
import os
import strutils
import strscans
import sequtils

setCurrentDir(getAppDir())

type
    OpType = enum opAddx, opNoop
    Op = object
        case kind: OpType
        of opAddx:
            amount: int
        of opNoop: discard

proc loadInstructions(): seq[Op] =
    let lines = readFile("input.txt").strip().splitLines()
    for line in lines:
        var amount: int
        if line == "noop":
            result.add(Op(kind: opNoop))
        elif line.scanf("addx $i", amount):
            result.add(Op(kind: opAddx, amount: amount))
        else:
            quit "Unable to parse line: " & line

iterator execute(ops: seq[Op]): int =
    var register = 1
    for op in ops:
        case op.kind:
        of opNoop: yield register
        of opAddx:
            yield register
            yield register
            register += op.amount
    yield register

proc first() =
    let startCycle = 20
    let cycleMult = 40
    let endCycle = 220

    let ops = loadInstructions()

    var signalStrength = 0
    for (cycle, register) in enumerate(1, execute(ops)):
        if (cycle - startCycle) mod cycleMult == 0 and cycle <= endCycle:
            echo cycle, ": ", register
            signalStrength += register * cycle

    echo "signalStrength: ", signalStrength


proc second() =
    let width = 40

    let ops = loadInstructions()

    for (cycle, register) in enumerate(execute(ops)):
        let crtHoriz = cycle mod width
        if crtHoriz == 0:
            stdout.write("\n")
        if abs(crtHoriz - register) < 2:
            stdout.write("#")
        else:
            stdout.write(".")
    stdout.flushFile()



# first()
second()
