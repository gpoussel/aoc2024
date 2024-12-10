package main

import (
	_ "embed"
	"fmt"
	"strings"
)

//go:embed example
var input string


func parseInput(input string) (ans [][]string) {
	for _, line := range strings.Split(input, "\r?\n") {
		ans = append(ans, strings.Split(line, ""))
	}
	return ans
}

func main() {
	input = strings.TrimRight(input, "\n")

	fmt.Println("Part 1:", part1(input))
	fmt.Println("Part 2:", part2(input))
}

func part1(input string) int {

	return 1
}

func part2(input string) int {

	return 2
}
