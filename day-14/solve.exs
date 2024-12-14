input = File.read!("input")

defmodule Solver do
    def parse_input(input) do
        input
        |> String.split("\n", trim: true)
        |> Enum.map(&parse_line/1)
    end

    # Example: p=0,4 v=3,-3
    def parse_line(line) do
        ~r|p=(-?\d+),(-?\d+) v=(-?\d+),(-?\d+)|
        |> Regex.run(line, capture: :all_but_first)
        |> Enum.map(&String.to_integer/1)
        |> then(fn [x1, y1, x2, y2] -> {{x1, y1}, {x2, y2}} end)
    end

    def parse_vector([x, y]) do
        {String.to_integer(String.trim(x)), String.to_integer(String.trim(y))}
    end

    def move(x, y, vx, vy, width, height, count) do
        {rem(x + count * (vx + width), width), rem(y + count * (vy + height), height)}
    end

    def part1(robots) do
        width = (if Enum.count(robots) == 12, do: 11, else: 101)
        height = (if Enum.count(robots) == 12, do: 7, else: 103)
        middlex = div(width - 1, 2)
        middley = div(height - 1, 2)
        robots
        |> Enum.map(fn {{x, y}, {vx, vy}} ->
            move(x, y, vx, vy, width, height, 100)
        end)
        |> Enum.reduce({0, 0, 0, 0}, fn {x, y}, {tl, tr, dl, dr} ->
            {tl, tr, dl, dr} = case {x, y} do
                {x, y} when x < middlex and y < middley -> {tl + 1, tr, dl, dr}
                {x, y} when x < middlex and y > middley -> {tl, tr + 1, dl, dr}
                {x, y} when x > middlex and y < middley -> {tl, tr, dl + 1, dr}
                {x, y} when x > middlex and y > middley -> {tl, tr, dl, dr + 1}
                _ -> {tl, tr, dl, dr}
            end
            {tl, tr, dl, dr}
        end)
        |> then(fn {tl, tr, dl, dr} -> tl * tr * dl * dr end)
    end

    def part2(robots) do
        if Enum.count(robots) == 12 do
            0
        else
            currentRobots = robots
            Enum.map(7000..7100, fn iteration ->
                currentRobots = Enum.map(currentRobots, fn {{x, y}, {vx, vy}} ->
                    {move(x, y, vx, vy, 101, 103, iteration), {vx, vy}}
                end)
                if rem(iteration, 100) == 0 do
                    IO.puts "Iteration: #{iteration}"
                end
                {
                    Enum.map(0..101, fn row ->
                        Enum.map(0..103, fn column ->
                            currentRobots
                            |> Enum.filter(fn {{x, y}, _} -> x == row and y == column end)
                            |> Enum.count()
                            |> then(fn x -> if x > 0, do: "#", else: "." end)
                        end)
                        |> Enum.join()
                        |> then(fn x -> Regex.match?(~r|.*##############################.*|, x) end)
                        |> then(fn x -> if x, do: 1, else: 0 end)
                    end)
                    |> Enum.sum(),
                    iteration
                }
            end)
            |> Enum.max()
            |> elem(1)
        end
    end
end

robots = Solver.parse_input(input)

IO.puts "Part 1: #{Solver.part1(robots)}"
IO.puts "Part 2: #{Solver.part2(robots)}"
