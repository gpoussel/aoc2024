const fs = require("fs")

// part one
function part1() {
  const lines = fs
    .readFileSync("input", "utf-8")
    .split("\n")
    .filter((e) => !!e)

  const xns = {}

  for (const line of lines) {
    const [first, second] = line.split("-")
    xns[first] ??= new Set()
    xns[first].add(second)
    xns[second] ??= new Set()
    xns[second].add(first)
  }

  const matches = new Set()

  for (const node of Object.keys(xns)) {
    if (node[0] !== "t") {
      continue
    }
    const xnArr = Array.from(xns[node])
    for (let i = 0; i < xnArr.length; i++) {
      for (let j = i + 1; j < xnArr.length; j++) {
        if (xns[xnArr[i]].has(xnArr[j])) {
          matches.add(JSON.stringify([node, xnArr[i], xnArr[j]].sort()))
        }
      }
    }
  }

  return matches.size
}

// part two
function part2() {
  const lines = fs
    .readFileSync("input", "utf-8")
    .split("\n")
    .filter((e) => !!e)

  const xns = {}

  for (const line of lines) {
    const [first, second] = line.split("-")
    xns[first] ??= new Set()
    xns[first].add(second)
    xns[second] ??= new Set()
    xns[second].add(first)
  }

  const matches = new Set()

  for (const node of Object.keys(xns)) {
    const xnArr = Array.from(xns[node])
    for (let i = 0; i < xnArr.length; i++) {
      for (let j = i + 1; j < xnArr.length; j++) {
        if (xns[xnArr[i]].has(xnArr[j])) {
          matches.add(JSON.stringify([node, xnArr[i], xnArr[j]].sort()))
        }
      }
    }
  }

  const nextMatches = (ms) => {
    const newMatches = new Set()

    for (const match of ms) {
      const matchArr = JSON.parse(match)
      for (const other of xns[matchArr[0]]) {
        if (matchArr.every((e) => xns[other].has(e))) {
          newMatches.add(JSON.stringify([...matchArr, other].sort()))
        }
      }
    }

    return newMatches
  }

  let currMatches = matches
  while (true) {
    const next = nextMatches(currMatches)
    if (next.size === 0) {
      break
    }
    currMatches = next
  }

  if (currMatches.size !== 1) {
    throw new Error()
  }

  const found = JSON.parse(Array.from(currMatches)[0]).sort().join(",")

  return found
}

console.log("Part 1:", part1())
console.log("Part 2:", part2())
