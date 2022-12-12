import algorithm
import deques
import os
import sequtils
import strscans
import strutils
import parseutils
import sugar

setCurrentDir(getAppDir())

type
    OpType = enum opMult, opPlus
    OperandType = enum opndInt, opndOld
    Operand = object
        case kind: OperandType
        of opndInt: value: int
        of opndOld: discard
    Monkey = ref object
        number: int
        items: Deque[int]
        opType: OpType
        operand: Operand
        testDivisibleBy: int
        trueTarget: int
        falseTarget: int
        inspectedCount: int
    ParseState = enum psMonkey, psBody

proc parseStartingItems(input: string, items: var Deque[int],
        start: int): int =
    let splits = input[start..<input.len].split(", ")
    for split in splits:
        items.addLast(parseInt(split))
    return input.len - start

proc parseOp(input: string, opType: var OpType, start: int): int =
    case input[start]
    of '+': opType = opPlus
    of '*': opType = opMult
    else:
        quit "Failed parsing operator: " & input[start]
    result.inc

proc parseOperand(input: string, operand: var Operand, start: int): int =
    var value: int
    if input[start..<input.len] == "old":
        operand = Operand(kind: opndOld)
        return 3
    result = input.parseInt(value, start)
    if result == 0:
        quit "Failed parsing operand: " & input
    operand = Operand(kind: opndInt, value: value)

proc loadMonkeys(): seq[Monkey] =
    let lines = readFile("input.txt").strip().splitLines()

    var state = psMonkey
    var monkey: Monkey
    for line in lines:
        case state
        of psMonkey:
            monkey = Monkey(items: initDeque[int](50))
            result.add(monkey)
            var monkeyNum: int
            if line.scanf("Monkey $i", monkeyNum):
                monkey.number = monkeyNum
                state = psBody
            else:
                quit "Expected Monkey header, got: " & line
        of psBody:
            var divisibleBy: int
            if line.strip() == "":
                state = psMonkey
            elif line.scanf("  Starting items: ${parseStartingItems}",
                    monkey.items): discard
            elif line.scanf("  Operation: new = old ${parseOp} ${parseOperand}",
                    monkey.opType, monkey.operand): discard
            elif line.scanf("  Test: divisible by $i",
                    divisibleBy):
                monkey.testDivisibleBy = divisibleBy
            elif line.scanf("    If true: throw to monkey $i",
                    monkey.trueTarget): discard
            elif line.scanf("    If false: throw to monkey $i",
                    monkey.falseTarget): discard
            else:
                quit "Failed parsing line: " & line


proc first() =
    let monkeys = loadMonkeys()
    for round in 0..<20:
        for monkey in monkeys:
            while monkey.items.len > 0:
                var item = monkey.items.popFirst()
                monkey.inspectedCount += 1
                case monkey.opType
                of opMult:
                    case monkey.operand.kind:
                    of opndOld:
                        item = item * item
                    of opndInt:
                        item = item * monkey.operand.value
                of opPlus:
                    case monkey.operand.kind
                    of opndOld:
                        item += item
                    of opndInt:
                        item += monkey.operand.value
                item = item div 3
                if item mod monkey.testDivisibleBy == 0:
                    monkeys[monkey.trueTarget].items.addLast(item)
                else:
                    monkeys[monkey.falseTarget].items.addLast(item)

    let active = sorted(monkeys, (x, y) => cmp(x.inspectedCount,
            y.inspectedCount), Descending)
    echo active[0].inspectedCount * active[1].inspectedCount


proc second() =
    let monkeys = loadMonkeys()
    let cd = monkeys.foldl(a * b.testDivisibleBy, 1)
    for round in 0..<10000:
        for monkey in monkeys:
            let trueTarget = monkeys[monkey.trueTarget]
            let falseTarget = monkeys[monkey.falseTarget]
            while monkey.items.len > 0:
                var item = monkey.items.popFirst()
                monkey.inspectedCount.inc()
                case monkey.opType
                of opMult:
                    case monkey.operand.kind:
                    of opndOld:
                        item *= item
                    of opndInt:
                        item *= monkey.operand.value
                of opPlus:
                    case monkey.operand.kind
                    of opndOld:
                        item += item
                    of opndInt:
                        item += monkey.operand.value
                item = item mod cd
                if item mod monkey.testDivisibleBy == 0:
                    trueTarget.items.addLast(item)
                else:
                    falseTarget.items.addLast(item)

    let active = sorted(monkeys, (x, y) => cmp(x.inspectedCount,
            y.inspectedCount), Descending)
    echo active[0].inspectedCount * active[1].inspectedCount


# first()
second()
