import scala.io.StdIn.readLine
import scala.collection.mutable.ListBuffer

class Point(val x: Int, val y: Int) {
    override def equals(obj: Any): Boolean = {
        obj match {
            case obj: Point => obj.x == x && obj.y == y
            case _ => false
        }
    }
    override def hashCode(): Int = {
        x.hashCode() * 31 + y.hashCode()
    }
    override def toString: String = s"($x, $y)"
}
class HikingPath(val paths: ListBuffer[Point]) {
}

def findNumber(grid: List[List[Int]], point: Point, target: Int): List[Point] = {
  val directions = List((0, 1), (0, -1), (1, 0), (-1, 0))
  val result = ListBuffer[Point]()
  for ((dx, dy) <- directions) {
    var x = point.x + dx
    var y = point.y + dy
    if (x >= 0 && x < grid.length && y >= 0 && y < grid(0).length && grid(x)(y) == target) {
      result += new Point(x, y)
    }
  }
  result.toList
}

@main def solve() =
  val source = scala.io.Source.fromFile("./input")
  val lines = try source.mkString finally source.close()
  var grid = lines.split("\r?\n").map(_.split("").toList.map(Integer.parseInt)).toList

  var part1 = 0
  var part2 = 0

  for((x,i) <- grid.zipWithIndex; (y,j) <- x.zipWithIndex) {
    if (y == 0) {
        var currentDigit = 0
        var paths = ListBuffer[HikingPath]()
        paths += new HikingPath(ListBuffer(new Point(i, j)))
        while (currentDigit != 9) {
            paths = paths.flatMap(path => {
                val lastPoint = path.paths.last
                val nextPoints = findNumber(grid, lastPoint, currentDigit + 1)
                nextPoints.map(nextPoint => {
                    val newPath = new HikingPath(path.paths.clone())
                    newPath.paths += nextPoint
                    newPath
                })
            })
            currentDigit += 1
        }

        part1 += paths.map(path => path.paths.last).toList.distinctBy(_.toString).length
        part2 += paths.toList.distinctBy(_.toString).length
    }
  }


  println("Part 1: " + part1)
  println("Part 2: " + part2)
