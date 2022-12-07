import os
import sequtils
import strutils
import strscans

setCurrentDir(getAppDir())

type
    EntryKind = enum ekDir, ekFile
    Entry = ref EntryObj
    EntryObj = object # Could remove this, and zoop it into the above?
        name: string
        parent: Entry
        case kind: EntryKind
        of ekDir:
            entries: seq[Entry]
            totalSize: int
        of ekFile: size: int

proc findOrCreateDir(parent: Entry, childName: string): Entry =
    assert parent.kind == ekDir
    for entry in parent.entries:
        if entry.name == childName:
            return entry
    parent.entries.add(Entry(name: childName, kind: ekDir, parent: parent))

proc createFile(parent: Entry, fileName: string, fileSize: int) =
    assert parent.kind == ekDir
    parent.entries.add(Entry(name: fileName, parent: parent, kind: ekFile, size: fileSize))
    var curDir = parent
    while curDir != nil:
        curDir.totalSize += fileSize
        curDir = curDir.parent


proc parse(input: string): Entry =
    result = Entry(name: "/", kind: ekDir)

    var curDir = result
    for line in input.splitLines():
        var fileSize: int
        var entryName: string
        if line == "$ cd /":
            curDir = result
        elif line == "$ cd ..":
            curDir = curDir.parent
            assert curDir != nil # root has no parent
        elif line.scanf("$$ cd $w", entryName):
            curDir = curDir.findOrCreateDir(entryName)
        elif line == "$ ls":
            discard
        elif line.scanf("dir $w", entryName):
            discard curDir.findOrCreateDir(entryName)
        elif line.scanf("$i $+$.", fileSize, entryName):
            curDir.createFile(entryName, fileSize)

proc print(entry: Entry, indent: int = 0) =
    let indentStr = repeat(' ', indent*2)
    case entry.kind
    of ekFile:
        echo indentStr, "- ", entry.name, " (file, size=", entry.size, ")"
    of ekDir:
        echo indentStr, "- ", entry.name, " (dir, totalSize=", entry.totalSize, ")"
        for child in entry.entries:
            print(child, indent + 1)


proc sumFirst(parent: Entry): int =
    assert parent.kind == ekDir
    if parent.totalSize <= 100000:
        result += parent.totalSize
    for child in parent.entries:
        if child.kind == ekDir:
            result += sumFirst(child)

proc first() =
    let input = readFile("input.txt").strip()
    let result = parse(input)
    echo sumFirst(result)
    # print(result)

proc findDirsAtLeast(entry: Entry, minSize: int, result: var seq[Entry]) =
    # assume entry meets minSize already
    assert entry.kind == ekDir
    for child in entry.entries:
        if child.kind == ekDir and child.totalSize >= minSize:
            result.add(child)
            findDirsAtLeast(child, minSize, result)


proc second() =
    let input = readFile("input.txt").strip()
    let result = parse(input)

    const totalAvailable = 70_000_000
    const unusedRequired = 30_000_000

    let unusedCurrent = totalAvailable - result.totalSize
    let wanted = unusedRequired - unusedCurrent

    echo "unused: ", unusedCurrent.formatSize()
    echo "wanted: ", wanted.formatSize()

    var deleteOptions: seq[Entry]
    findDirsAtLeast(result, unusedRequired - unusedCurrent, deleteOptions)
    for option in deleteOptions:
        echo option.name, " - ", option.totalSize.formatSize()

    echo "delete me:" ,deleteOptions.foldl(if a.totalSize > b.totalSize: b else: a, result)[]


# first()
second()