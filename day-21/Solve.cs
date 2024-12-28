internal static class Solve
{
    private record Vector(int X, int Y);

    private record Problem(char[,] Grid, Vector Start, Vector End);

    private static readonly Vector[] Directions =
    {
        new Vector(0, 1),
        new Vector(0, -1),
        new Vector(1, 0),
        new Vector(-1, 0)
    };

    public static void Main(string[] args)
    {
        try
        {
            var testCases = new[]
            {
                ("input_01.txt", "output_01_01.txt", 1, 2),
                ("input_02.txt", "output_01_02.txt", 100, 2),
                ("input_01.txt", "output_02_01.txt", 50, 20),
                ("input_02.txt", "output_02_02.txt", 100, 20)
            };

            foreach (var (inputFile, outputFile, saveThreshold, cheatLength) in testCases)
            {
                Solve(inputFile, outputFile, saveThreshold, cheatLength);
            }
        }
        catch (Exception ex)
        {
            Console.Error.WriteLine($"Error: {ex.Message}");
        }
    }

    private static void Solve(string inputFile, string outputFile, int saveThreshold, int cheatLength)
    {
        if (string.IsNullOrWhiteSpace(inputFile))
            throw new ArgumentException("Input file path cannot be null or whitespace.");

        if (string.IsNullOrWhiteSpace(outputFile))
            throw new ArgumentException("Output file path cannot be null or whitespace.");

        var problem = ParseInput(inputFile);
        if (problem.Start == null || problem.End == null)
            throw new InvalidOperationException("Start (S) or End (E) position not found in the input grid.");

        var distances = ComputeDistancesToEnd(problem);

        var cheatsCount = CalculateCheatsCount(problem, distances, saveThreshold, cheatLength);

        File.WriteAllText(outputFile, cheatsCount.ToString());
    }

    private static int CalculateCheatsCount(Problem problem, int[,] distances, int saveThreshold, int cheatLength)
    {
        int count = 0;
        var current = problem.Start;

        while (current != problem.End)
        {
            var next = GetNextPositionOnShortestPath(problem, distances, current);

            var exits = GetAllCheatExits(problem, distances, current, cheatLength);

            foreach (var (exit, distanceInCheat) in exits)
            {
                int legalDistance = distances[next.X, next.Y];
                int cheatDistance = distanceInCheat + distances[exit.X, exit.Y] - 1;
                int timeSaved = legalDistance - cheatDistance;

                if (timeSaved >= saveThreshold)
                {
                    count++;
                }
            }

            current = next;
        }

        return count;
    }

    private static Vector GetNextPositionOnShortestPath(Problem problem, int[,] distances, Vector current)
    {
        foreach (var direction in Directions)
        {
            var next = new Vector(current.X + direction.X, current.Y + direction.Y);

            if (!IsWithinBounds(next, problem.Grid) || problem.Grid[next.X, next.Y] == '#')
            {
                continue;
            }

            if (distances[next.X, next.Y] != -1 &&
                distances[next.X, next.Y] < distances[current.X, current.Y])
            {
                return next;
            }
        }

        throw new InvalidOperationException("No next position found along the shortest path.");
    }

    private static IEnumerable<(Vector, int)> GetAllCheatExits(Problem problem, int[,] distances, Vector entrance, int cheatLength)
    {
        var exits = new Dictionary<Vector, int>();
        var queue = new Queue<(Vector pos, int distance)>();
        var visited = new HashSet<Vector>();

        queue.Enqueue((entrance, 0));

        while (queue.Count > 0)
        {
            var (current, stepsTaken) = queue.Dequeue();

            if (!visited.Add(current))
            {
                continue;
            }

            if (stepsTaken > cheatLength)
            {
                continue;
            }

            if (distances[current.X, current.Y] != -1 &&
                distances[current.X, current.Y] < distances[entrance.X, entrance.Y])
            {
                if (!exits.TryGetValue(current, out var existingDistance) || stepsTaken < existingDistance)
                {
                    exits[current] = stepsTaken;
                }
            }

            foreach (var direction in Directions)
            {
                var next = new Vector(current.X + direction.X, current.Y + direction.Y);
                if (!IsWithinBounds(next, problem.Grid) || visited.Contains(next))
                {
                    continue;
                }
                queue.Enqueue((next, stepsTaken + 1));
            }
        }

        return exits.Select(x => (x.Key, x.Value));
    }

    private static int[,] ComputeDistancesToEnd(Problem problem)
    {
        int width = problem.Grid.GetLength(0);
        int height = problem.Grid.GetLength(1);

        var distances = InitializeDistanceMatrix(width, height);
        var visited = new HashSet<Vector>();
        var queue = new Queue<(Vector pos, int distance)>();

        queue.Enqueue((problem.End, 0));

        while (queue.Count > 0)
        {
            var (current, distance) = queue.Dequeue();

            if (!visited.Add(current)) continue;
            distances[current.X, current.Y] = distance;

            if (current == problem.Start)
            {
                continue;
            }

            foreach (var direction in Directions)
            {
                var next = new Vector(current.X + direction.X, current.Y + direction.Y);

                if (IsWithinBounds(next, problem.Grid) &&
                    !visited.Contains(next) &&
                    problem.Grid[next.X, next.Y] != '#')
                {
                    queue.Enqueue((next, distance + 1));
                }
            }
        }

        return distances;
    }

    private static Problem ParseInput(string file)
    {
        var lines = File.ReadAllLines(file);
        if (lines.Length == 0)
            throw new InvalidOperationException("Input file is empty.");

        int width = lines[0].Length;
        int height = lines.Length;
        char[,] grid = new char[width, height];

        Vector? start = null;
        Vector? end = null;

        for (int y = 0; y < height; y++)
        {
            string line = lines[y];

            if (line.Length != width)
                throw new InvalidOperationException("All lines in the input file must have the same width.");

            for (int x = 0; x < width; x++)
            {
                char c = line[x];
                if (c == 'S')
                {
                    start = new Vector(x, y);
                    grid[x, y] = '.';
                }
                else if (c == 'E')
                {
                    end = new Vector(x, y);
                    grid[x, y] = '.';
                }
                else
                {
                    grid[x, y] = c;
                }
            }
        }

        return new Problem(grid, start ?? throw new InvalidOperationException("No start (S) found in input."),
                                 end ?? throw new InvalidOperationException("No end (E) found in input."));
    }

    private static int[,] InitializeDistanceMatrix(int width, int height)
    {
        var distances = new int[width, height];
        for (int i = 0; i < width; i++)
            for (int j = 0; j < height; j++)
                distances[i, j] = -1;

        return distances;
    }

    private static bool IsWithinBounds(Vector pos, char[,] grid)
    {
        return pos.X >= 0 && pos.X < grid.GetLength(0) &&
               pos.Y >= 0 && pos.Y < grid.GetLength(1);
    }
}
