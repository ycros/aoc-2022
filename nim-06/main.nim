import os
import deques
import std/setutils

setCurrentDir(getAppDir())

proc findStart(buffer: string, amount: int = 4) =
    var last4: Deque[char]
    for i, c in buffer:
        if last4.len >= amount:
            if last4.toSet().len == amount:
                echo i
                break
            last4.popLast()
        last4.addFirst(c)

proc first() =
    # let buffers = readFile("samples.txt").splitLines()
    # for buffer in buffers:
    #     findStart(buffer)

    let buffer = readFile("input.txt")
    findStart(buffer)

proc second() =
    # let buffers = readFile("samples.txt").splitLines()
    # for buffer in buffers:
    #     findStart(buffer, 14)

    let buffer = readFile("input.txt")
    findStart(buffer, 14)

# first()
second()