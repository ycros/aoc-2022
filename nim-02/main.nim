import sequtils
import strscans
import strutils

type
    Shape = enum rock, paper, scissors
    Round = object
        opponent: Shape
        me: Shape
    Outcome = enum loss, draw, win

proc score(shape: Shape): int =
    case shape
    of rock: return 1
    of paper: return 2
    of scissors: return 3

proc score(outcome: Outcome): int =
    case outcome
    of win: return 6
    of loss: return 0
    of draw: return 3

proc outcome(round: Round): Outcome =
    if round.me == round.opponent: return draw
    case round.me
    of rock: return if round.opponent == paper: loss else: win
    of paper: return if round.opponent == scissors: loss else: win
    of scissors: return if round.opponent == rock: loss else: win

proc chooseShape(desiredOutcome: Outcome, opponentShape: Shape): Shape =
    if desiredOutcome == draw: return opponentShape
    case opponentShape
    of rock: return if desiredOutcome == win: paper else: scissors
    of paper: return if desiredOutcome == win: scissors else: rock
    of scissors: return if desiredOutcome == win: rock else: paper

proc score(round: Round): int =
    let outcomeScore = round.outcome().score()
    let shapeScore = round.me.score()
    return outcomeScore + shapeScore

proc parseShape(c: char): Shape =
    case c
    of 'A', 'X':
        return rock
    of 'B', 'Y':
        return paper
    of 'C', 'Z':
        return scissors
    else:
        quit "Tried to parse invalid shape: " & c

proc parseOutcome(c: char): Outcome =
    case c
    of 'X': return loss
    of 'Y': return draw
    of 'Z': return win
    else:
        quit "Tried to parse invalid outcome: " & c

proc firstParseLine(line: string): Round =
    var opponentShapeRaw, meShapeRaw: char
    if scanf(line, "$c $c", opponentShapeRaw, meShapeRaw):
        let opponentShape = parseShape(opponentShapeRaw)
        let meShape = parseShape(meShapeRaw)
        return Round(me: meShape, opponent: opponentShape)

proc firstParse(input: string): seq[Round] =
    return input.strip().splitLines().map(firstParseLine)

proc first() =
    let rounds = readFile("input.txt").firstParse()
    echo rounds.foldl(a + b.score(), 0)

proc parseLine(line: string): Round =
    var opponentShapeRaw, outcomeRaw: char
    if scanf(line, "$c $c", opponentShapeRaw, outcomeRaw):
        let opponentShape = parseShape(opponentShapeRaw)
        let outcome = parseOutcome(outcomeRaw)
        let meShape = chooseShape(outcome, opponentShape)
        return Round(me: meShape, opponent: opponentShape)

proc parse(input: string): seq[Round] =
    return input.strip().splitLines().map(parseLine)

proc second() =
    let rounds = readFile("input.txt").parse()
    echo rounds.foldl(a + b.score(), 0)

second()
