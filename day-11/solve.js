const fs = require("fs")

const originalInput = fs
  .readFileSync("./input", "utf8")
  .trim()
  .split(/\r?\n/)[0]
  .split(" ")
  .map(Number)

const results = Object.fromEntries(
  Array(100)
    .fill(0)
    .map((_, index) => {
      return [index, {}]
    })
)

function computeNumber(stone) {
  if (stone === 0) {
    return [1]
  }
  const stoneString = `${stone}`
  if (stoneString.length % 2 === 0) {
    const halfLength = stoneString.length / 2
    return [
      parseInt(stoneString.substring(0, halfLength), 10),
      parseInt(stoneString.substring(halfLength), 10),
    ]
  }
  return [stone * 2024]
}

function iterateNumber(number, iteration) {
  if (iteration % 10 === 0)
    console.log({
      number,
      iteration,
      cache: Object.keys(results[iteration]).length,
    })
  if (!results[iteration][number]) {
    if (iteration > 0) {
      results[iteration][number] = computeNumber(number)
        .map((number) => iterateNumber(number, iteration - 1))
        .reduce((acc, val) => acc + val, 0)
    } else {
      results[iteration][number] = 1
    }
  }
  return results[iteration][number]
}

let part1 = 0

for (const stone of originalInput) {
  part1 += iterateNumber(stone, 25)
}
console.log("Part1: ", "aoc submit 1", part1)

let part2 = 0
for (const stone of originalInput) {
  console.log("Stone: ", stone)
  part2 += iterateNumber(stone, 75)
}

console.log("Part2: ", "aoc submit 2", part2)
