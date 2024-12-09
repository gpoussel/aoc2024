import scala.io.StdIn.readLine

@main def helloInteractive() =
  val source = scala.io.Source.fromFile("./example")
  val lines = try source.mkString finally source.close()
  println(lines.split("\r?\n").toList)
