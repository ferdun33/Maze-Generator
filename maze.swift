// maze.swift
import Foundation

class Maze {
    var grid: [[Character]]
    var width: Int
    var height: Int
    var start: (Int, Int)
    var end: (Int, Int)
    var solution: [(Int, Int)]?

    init(w: Int = 21, h: Int = 21) {
        self.width = w % 2 == 0 ? w + 1 : w
        self.height = h % 2 == 0 ? h + 1 : h
        self.start = (1, 1)
        self.end = (self.height - 2, self.width - 2)
        self.grid = Array(repeating: Array(repeating: "#", count: self.width), count: self.height)
        generate()
    }

    func generate() {
        grid = Array(repeating: Array(repeating: "#", count: width), count: height)
        grid[1][1] = " "
        var stack = [(1, 1)]
        let dirs = [(0, 2), (0, -2), (2, 0), (-2, 0)]
        while !stack.isEmpty {
            let (cx, cy) = stack.last!
            var neighbours: [(Int, Int, Int, Int)] = []
            for (dx, dy) in dirs {
                let nx = cx + dx, ny = cy + dy
                if nx > 0 && nx < height - 1 && ny > 0 && ny < width - 1 && grid[nx][ny] == "#" {
                    neighbours.append((nx, ny, dx / 2, dy / 2))
                }
            }
            if !neighbours.isEmpty {
                let n = neighbours.randomElement()!
                grid[cx + n.2][cy + n.3] = " "
                grid[n.0][n.1] = " "
                stack.append((n.0, n.1))
            } else {
                stack.removeLast()
            }
        }
        grid[start.0][start.1] = "S"
        grid[end.0][end.1] = "E"
        solution = nil
    }

    func display() {
        for row in grid {
            print(String(row))
        }
    }

    func solve() -> [(Int, Int)]? {
        var queue = [start]
        var visited = Set<String>()
        visited.insert("\(start.0),\(start.1)")
        var parent: [String: (Int, Int)] = [:]
        let dirs = [(0, 1), (0, -1), (1, 0), (-1, 0)]
        while !queue.isEmpty {
            let (cx, cy) = queue.removeFirst()
            if (cx, cy) == end { break }
            for (dx, dy) in dirs {
                let nx = cx + dx, ny = cy + dy
                if nx >= 0 && nx < height && ny >= 0 && ny < width && grid[nx][ny] != "#" {
                    let key = "\(nx),\(ny)"
                    if !visited.contains(key) {
                        visited.insert(key)
                        parent[key] = (cx, cy)
                        queue.append((nx, ny))
                    }
                }
            }
        }
        if parent["\(end.0),\(end.1)"] == nil && end != start {
            solution = nil
            return nil
        }
        var path: [(Int, Int)] = []
        var cur: (Int, Int)? = end
        while let c = cur {
            path.insert(c, at: 0)
            if c == start { break }
            cur = parent["\(c.0),\(c.1)"]
        }
        solution = path
        return path
    }

    func displaySolution() {
        if solution == nil { _ = solve() }
        var display = grid
        for p in solution!.dropFirst().dropLast() {
            if display[p.0][p.1] != "S" && display[p.0][p.1] != "E" {
                display[p.0][p.1] = "o"
            }
        }
        for row in display {
            print(String(row))
        }
    }

    func save(filename: String) throws {
        let content = grid.map { String($0) }.joined(separator: "\n")
        try content.write(toFile: filename, atomically: true, encoding: .utf8)
    }

    func load(filename: String) throws {
        let content = try String(contentsOfFile: filename, encoding: .utf8)
        let lines = content.split(separator: "\n").map { String($0) }.filter { !$0.isEmpty }
        grid = lines.map { Array($0) }
        height = grid.count
        width = grid[0].count
        for i in 0..<height {
            for j in 0..<width {
                if grid[i][j] == "S" { start = (i, j) }
                else if grid[i][j] == "E" { end = (i, j) }
            }
        }
        solution = nil
    }
}

func main() {
    let args = CommandLine.arguments.dropFirst()
    let w = args.count > 0 ? Int(args[0]) ?? 21 : 21
    let h = args.count > 1 ? Int(args[1]) ?? 21 : 21
    var maze = Maze(w: w, h: h)
    print("🧩 Maze Generator")
    print("Commands: generate, solve, save <file>, load <file>, quit")
    while true {
        print("> ", terminator: "")
        guard let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) else { continue }
        let parts = input.split(separator: " ").map(String.init)
        if parts.isEmpty { continue }
        switch parts[0] {
        case "quit":
            return
        case "generate":
            maze = Maze(w: w, h: h)
            maze.display()
        case "solve":
            maze.displaySolution()
        case "save":
            if parts.count > 1 {
                do {
                    try maze.save(filename: parts[1])
                    print("Saved to \(parts[1])")
                } catch {
                    print("Error saving.")
                }
            }
        case "load":
            if parts.count > 1 {
                do {
                    try maze.load(filename: parts[1])
                    print("Loaded from \(parts[1])")
                    maze.display()
                } catch {
                    print("Error loading file.")
                }
            }
        default:
            print("Unknown command.")
        }
    }
}

main()
