// Maze.cs
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

class Maze
{
    private char[][] grid;
    private int width, height;
    private (int x, int y) start, end;
    private List<(int x, int y)> solution;
    private Random rand = new Random();

    public Maze(int w = 21, int h = 21)
    {
        width = w % 2 == 0 ? w + 1 : w;
        height = h % 2 == 0 ? h + 1 : h;
        start = (1, 1);
        end = (height - 2, width - 2);
        Generate();
    }

    public void Generate()
    {
        grid = new char[height][];
        for (int i = 0; i < height; i++)
        {
            grid[i] = Enumerable.Repeat('#', width).ToArray();
        }
        grid[1][1] = ' ';
        var stack = new List<(int x, int y)> { (1, 1) };
        int[,] dirs = { { 0, 2 }, { 0, -2 }, { 2, 0 }, { -2, 0 } };
        while (stack.Count > 0)
        {
            var (cx, cy) = stack[stack.Count - 1];
            var neighbours = new List<(int x, int y, int wx, int wy)>();
            for (int i = 0; i < 4; i++)
            {
                int nx = cx + dirs[i, 0], ny = cy + dirs[i, 1];
                if (nx > 0 && nx < height - 1 && ny > 0 && ny < width - 1 && grid[nx][ny] == '#')
                {
                    neighbours.Add((nx, ny, dirs[i, 0] / 2, dirs[i, 1] / 2));
                }
            }
            if (neighbours.Count > 0)
            {
                var n = neighbours[rand.Next(neighbours.Count)];
                grid[cx + n.wx][cy + n.wy] = ' ';
                grid[n.x][n.y] = ' ';
                stack.Add((n.x, n.y));
            }
            else
            {
                stack.RemoveAt(stack.Count - 1);
            }
        }
        grid[start.x][start.y] = 'S';
        grid[end.x][end.y] = 'E';
        solution = null;
    }

    public void Display()
    {
        foreach (var row in grid)
            Console.WriteLine(new string(row));
    }

    public List<(int x, int y)> Solve()
    {
        var queue = new Queue<(int x, int y)>();
        queue.Enqueue(start);
        var visited = new HashSet<(int x, int y)> { start };
        var parent = new Dictionary<(int x, int y), (int x, int y)>();
        int[,] dirs = { { 0, 1 }, { 0, -1 }, { 1, 0 }, { -1, 0 } };
        while (queue.Count > 0)
        {
            var (cx, cy) = queue.Dequeue();
            if (cx == end.x && cy == end.y) break;
            for (int i = 0; i < 4; i++)
            {
                int nx = cx + dirs[i, 0], ny = cy + dirs[i, 1];
                if (nx >= 0 && nx < height && ny >= 0 && ny < width && grid[nx][ny] != '#')
                {
                    if (!visited.Contains((nx, ny)))
                    {
                        visited.Add((nx, ny));
                        parent[(nx, ny)] = (cx, cy);
                        queue.Enqueue((nx, ny));
                    }
                }
            }
        }
        if (!parent.ContainsKey(end) && end != start)
        {
            solution = null;
            return null;
        }
        var path = new List<(int x, int y)>();
        var cur = end;
        while (true)
        {
            path.Insert(0, cur);
            if (cur == start) break;
            cur = parent[cur];
        }
        solution = path;
        return path;
    }

    public void DisplaySolution()
    {
        if (solution == null) Solve();
        var display = grid.Select(row => row.ToArray()).ToArray();
        for (int i = 1; i < solution.Count - 1; i++)
        {
            var (x, y) = solution[i];
            if (display[x][y] != 'S' && display[x][y] != 'E')
                display[x][y] = 'o';
        }
        foreach (var row in display)
            Console.WriteLine(new string(row));
    }

    public void Save(string filename)
    {
        using var writer = new StreamWriter(filename);
        foreach (var row in grid)
            writer.WriteLine(new string(row));
    }

    public void Load(string filename)
    {
        var lines = File.ReadAllLines(filename).Where(line => !string.IsNullOrWhiteSpace(line)).ToList();
        grid = lines.Select(line => line.ToCharArray()).ToArray();
        height = grid.Length;
        width = grid[0].Length;
        for (int i = 0; i < height; i++)
            for (int j = 0; j < width; j++)
            {
                if (grid[i][j] == 'S') start = (i, j);
                else if (grid[i][j] == 'E') end = (i, j);
            }
        solution = null;
    }

    static void Main(string[] args)
    {
        int w = 21, h = 21;
        if (args.Length > 0) int.TryParse(args[0], out w);
        if (args.Length > 1) int.TryParse(args[1], out h);
        var maze = new Maze(w, h);
        Console.WriteLine("🧩 Maze Generator");
        Console.WriteLine("Commands: generate, solve, save <file>, load <file>, quit");
        while (true)
        {
            Console.Write("> ");
            var parts = Console.ReadLine()?.Trim().Split(' ');
            if (parts == null || parts.Length == 0) continue;
            switch (parts[0])
            {
                case "quit": return;
                case "generate":
                    maze = new Maze(w, h);
                    maze.Display();
                    break;
                case "solve":
                    maze.DisplaySolution();
                    break;
                case "save":
                    if (parts.Length > 1)
                    {
                        maze.Save(parts[1]);
                        Console.WriteLine($"Saved to {parts[1]}");
                    }
                    break;
                case "load":
                    if (parts.Length > 1)
                    {
                        try
                        {
                            maze.Load(parts[1]);
                            Console.WriteLine($"Loaded from {parts[1]}");
                            maze.Display();
                        }
                        catch { Console.WriteLine("Error loading file."); }
                    }
                    break;
                default:
                    Console.WriteLine("Unknown command.");
                    break;
            }
        }
    }
}
