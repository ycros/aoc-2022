import os
import sequtils
import std/setutils
import strutils
import sugar

proc priority(item: char): int =
    case item
    of 'a'..'z':
        return int(item) - int('a') + 1
    of 'A'..'Z':
        return int(item) - int('A') + 27
    else:
        quit "item out of range: " & item

proc first() =
    let lines = readFile("input.txt").strip().splitLines()

    var totalPriority = 0
    for line in lines:
        let compartments = @line.distribute(2)
        for i in compartments[0]:
            if i in compartments[1]:
                totalPriority += priority(i)
                break

    echo totalPriority

proc second() =
    let lines = readFile("input.txt").strip().splitLines()
    assert lines.len mod 3 == 0
    var totalPriority = 0
    for elves in lines.distribute(lines.len div 3):
        let common = elves.map(el => toSet(el)).foldl(a * b)
        assert common.len == 1
        totalPriority += priority(common.toSeq()[0])
    echo totalPriority

setCurrentDir(getAppDir())
# first()
second()
