import { readFileSync } from "node:fs"

function normalize(input: string) {
  return input.trim()
}

function lines(input: string) {
  return normalize(input).split("\n")
}

function blocks(input: string) {
  return normalize(input).split(/\n\n+/)
}

function readGrid(input: string) {
  return lines(input).map((line) => line.split(""))
}

function columns<K>(grid: K[][]) {
  return Array.from({ length: grid[0].length }, () => 0).map((_, i) =>
    grid.map((row) => row[i])
  )
}

function parseInput(input: string) {
  const grids = blocks(input).map((block) => readGrid(block))
  const locks = grids
    .filter((g) => g[0].every((c) => c === "#"))
    .map((grid) => columns(grid).map((c) => c.indexOf(".") - 1))
  const keys = grids
    .filter((g) => g[g.length - 1].every((c) => c === "#"))
    .map((grid) => columns(grid).map((c) => c.length - c.indexOf("#") - 1))
  return { locks, keys }
}

function part1(inputString: string) {
  const { locks, keys } = parseInput(inputString)
  return locks
    .flatMap((lock) =>
      keys.map((key) => (lock.every((l, i) => l + key[i] <= 5) ? 1 : 0))
    )
    .reduce((a: number, b: number) => a + b, 0)
}

const file = readFileSync("input", "utf-8")
console.log("Part 1:", part1(file))
