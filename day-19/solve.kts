import java.io.File

class Day19(input: List<String>) {

    private val patterns: List<String> = input.first().split(",").map { it.trim() }
    private val designs: List<String> = input.drop(2)

    fun solvePart1(): Int =
        designs.count { makeDesign(it) > 0 }

    fun solvePart2(): Long =
        designs.sumOf { makeDesign(it) }

    private fun makeDesign(design: String, cache: MutableMap<String, Long> = mutableMapOf()): Long =
        if (design.isEmpty()) 1
        else cache.getOrPut(design) {
            patterns.filter { design.startsWith(it) }.sumOf {
                makeDesign(design.removePrefix(it), cache)
            }
        }
}

    
val p1 = Day19(File("input").readLines()).solvePart1()
println("Part 1: " + p1)

val p2 = Day19(File("input").readLines()).solvePart2()
println("Part 2: " + p2)
