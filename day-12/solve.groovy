def input = new File("input").readLines()
        .collect { it.split("").collect { c -> c as char} }

class Helper {
    static def findStartingPoint(grid) {
        for (i in grid.indices) {
            for (j in grid[i].indices) {
                if (grid[i][j] != '_') {
                    return new Tuple2(i, j)
                }
            }
        }
        return new Tuple2(-1, -1)
    }
}

def DIRECTIONS = [
    new Tuple3(1, 0, "down"),
    new Tuple3(-1, 0, "up"),
    new Tuple3(0, 1, "right"),
    new Tuple3(0, -1, "left")
]

def part1 = 0
def part2 = 0

while (true) {
    def startingPoint = Helper.findStartingPoint(input)
    if (startingPoint.first == -1) {
        break
    }

    def queue = [startingPoint]
    def visited = new HashSet<Tuple2>()
    def element = input[startingPoint.first][startingPoint.second]

    while (!queue.isEmpty()) {
        def current = queue.remove(0)

        if (visited.contains(current)) {
            continue
        }

        visited.add(current)

        def i = current.first
        def j = current.second
        input[i][j] = '_'

        for (direction in DIRECTIONS) {
            def newI = i + direction.first
            def newJ = j + direction.second

            if (newI < 0 || newI >= input.size() || newJ < 0 || newJ >= input[newI].size()) {
                continue
            }
            if (input[newI][newJ] != element) {
                continue
            }

            queue.add(new Tuple2(newI, newJ))
        }
    }
    def area = visited.size()

    def verticalEdges = []
    def horizontalEdges = []

    def perimeter = 0
    visited.each { current ->
        def i = current.first
        def j = current.second

        for (direction in DIRECTIONS) {
            def newI = i + direction.first
            def newJ = j + direction.second

            if (visited.contains(new Tuple2(newI, newJ))) {
                continue
            }

            perimeter++

            def edgePosition = new Tuple3(i + (direction.first > 0 ? 1 : 0), j + (direction.second > 0 ? 1 : 0), direction.third)
            if (direction.third == "up" || direction.third == "down") {
                horizontalEdges.add(edgePosition)
            } else {
                verticalEdges.add(edgePosition)
            }
        }
    }

    part1 += area * perimeter

    def horizontalContiguousEdges = []
    horizontalEdges.sort { a, b -> 
        if (a.first == b.first) {
            a.second <=> b.second
        } else {
            a.first <=> b.first
        }
    }
    horizontalEdges.each { edge ->
        if (horizontalContiguousEdges.isEmpty()) {
            horizontalContiguousEdges.add(new Tuple3(edge.first, edge.second, edge.third))
        } else {
            def last = horizontalContiguousEdges.last()
            if (last.first == edge.first && last.second + 1 == edge.second && last.third == edge.third) {
                horizontalContiguousEdges.pop()
            }
            horizontalContiguousEdges.add(new Tuple3(edge.first, edge.second, edge.third))
        }
    }

    def perimeter2 = horizontalContiguousEdges.size() * 2
    part2 += area * perimeter2
}

println "Part 1: ${part1}"

println "Part 2: ${part2}"
