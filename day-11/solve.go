package main

import (
	_ "embed"
	"fmt"
	"strconv"
	"strings"
)

//go:embed input
var input string

var results map[int]map[uint64]uint64 = make(map[int]map[uint64]uint64)

func computeNumber(stone uint64) []uint64 {
	if (stone == 0) {
		result := make([]uint64, 1)
		result[0] = 1
		return result
	}
	stoneString := strconv.FormatUint(stone, 10)
	if len(stoneString)%2 == 0 {
		halfLength := len(stoneString) / 2
		firstHalfInt, _ := strconv.ParseInt(stoneString[:halfLength], 10, 64)
		firstHalf := uint64(firstHalfInt)
		secondHalfInt, _ := strconv.ParseInt(stoneString[halfLength:], 10, 64)
		secondHalf := uint64(secondHalfInt)
		
		result := make([]uint64, 2)
		result[0] = firstHalf
		result[1] = secondHalf
		return result
	} else {
		result := make([]uint64, 1)
		result[0] = stone*2024
		return result
	}
}

func iterateNumber(number uint64, iteration int) uint64 {
	if iteration == 0 {
		return 1
	}
	iterationResults, exists := results[iteration]
	if !exists {
		results[iteration] = make(map[uint64]uint64)
	}

	numberResult, numberExists := iterationResults[number]
	if numberExists {
		return numberResult
	}
	childNumbers := computeNumber(number)
	var sum uint64 = 0
	for _, childNumber := range childNumbers {
		sum += iterateNumber(childNumber, iteration - 1)
	}
	results[iteration][number] = sum
	return results[iteration][number]
}


func countStones(input string, maxIteration int) uint64 {
	originalInput := strings.Fields(strings.TrimSpace(input))

	var result uint64 = 0
	for _, v := range originalInput {
		stoneInt, _ := strconv.ParseInt(v, 10, 64)
		stone := uint64(stoneInt)
		result += iterateNumber(stone, maxIteration)
	}
	return result
}

func main() {
	input = strings.TrimRight(input, "\n")

	fmt.Printf("Part 1: %d\n", part1(input))
	fmt.Printf("Part 2: %d", part2(input))
}

func part1(input string) uint64 {
	return countStones(input, 25)
}

func part2(input string) uint64 {
	return countStones(input, 75)
}
