import std/algorithm
import std/math
import std/strutils
import std/sequtils
import std/sugar

type Elf = object
    items: seq[int]
    totalCalories: int

# proc total(elf: Elf): int =
#     return elf.items.sum()

proc groupBy[T](sequence: seq[T], predicate: (el: T) -> bool): seq[seq[T]] =
    var groupItems: seq[T]
    for el in sequence:
        if predicate(el):
            result.add(groupItems)
            groupItems = @[]
        else:
            groupItems.add(el)
    if groupItems.len > 0:
        result.add(groupItems)

proc parse(input: string): seq[Elf] =
    let lineGroups = input.strip().splitLines().groupBy(line => line == "")
    # lol, "experimental" syntax
    # return lineGroups.map do (g: seq[string]) -> Elf:
    #     let items = g.map(parseInt)
    #     Elf(items: items, totalCalories: items.sum())
    return lineGroups.map proc (g: seq[string]): Elf =
        let items = g.map(parseInt)
        Elf(items: items, totalCalories: items.sum())

proc first() =
    # let elves = readFile("sample.txt").parse()
    let elves = readFile("input.txt").parse()
    echo foldl(elves, max(a, b.items.sum()), 0)

proc second() =
    # var elves = readFile("sample.txt").parse()
    var elves = readFile("input.txt").parse()
    elves.sort((a, b) => cmp(a.totalCalories, b.totalCalories), Descending)
    echo elves[0..2].foldl(a + b.totalCalories, 0)

second()

# echo groupBy(@['a', 'b', 'c', 'd', 'a', 'b', 'c', 'e'], el => el == 'c')