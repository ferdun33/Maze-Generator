// maze.go
package main

import (
	"bufio"
	"fmt"
	"math/rand"
	"os"
	"strconv"
	"strings"
	"time"
)

type Maze struct {
	grid     [][]string
	width    int
	height   int
	start    [2]int
	end      [2]int
	solution [][2]int
}

func NewMaze(w, h int) *Maze {
	if w%2 == 0 {
		w++
	}
	if h%2 == 0 {
		h++
	}
	m := &Maze{
		width:  w,
		height: h,
		start:  [2]int{1, 1},
		end:    [2]int{h - 2, w - 2},
	}
	m.generate()
	return m
}

func (m *Maze) generate() {
	m.grid = make([][]string, m.height)
	for i := range m.grid {
		m.grid[i] = make([]string, m.width)
		for j := range m.grid[i] {
			m.grid[i][j] = "#"
		}
	}
	m.grid[1][1] = " "
	stack := [][2]int{{1, 1}}
	dirs := [][2]int{{0, 2}, {0, -2}, {2, 0}, {-2, 0}}
	for len(stack) > 0 {
		cx, cy := stack[len(stack)-1][0], stack[len(stack)-1][1]
		neighbours := [][4]int{}
		for _, d := range dirs {
			nx, ny := cx+d[0], cy+d[1]
			if nx > 0 && nx < m.height-1 && ny > 0 && ny < m.width-1 && m.grid[nx][ny] == "#" {
				neighbours = append(neighbours, [4]int{nx, ny, d[0] / 2, d[1] / 2})
			}
		}
		if len(neighbours) > 0 {
			n := neighbours[rand.Intn(len(neighbours))]
			m.grid[cx+n[2]][cy+n[3]] = " "
			m.grid[n[0]][n[1]] = " "
			stack = append(stack, [2]int{n[0], n[1]})
		} else {
			stack = stack[:len(stack)-1]
		}
	}
	m.grid[m.start[0]][m.start[1]] = "S"
	m.grid[m.end[0]][m.end[1]] = "E"
	m.solution = nil
}

func (m *Maze) display() {
	for _, row := range m.grid {
		fmt.Println(strings.Join(row, ""))
	}
}

func (m *Maze) solve() [][2]int {
	start := m.start
	end := m.end
	queue := [][2]int{start}
	visited := map[[2]int]bool{start: true}
	parent := map[[2]int][2]int{}
	dirs := [][2]int{{0, 1}, {0, -1}, {1, 0}, {-1, 0}}
	for len(queue) > 0 {
		cx, cy := queue[0][0], queue[0][1]
		queue = queue[1:]
		if cx == end[0] && cy == end[1] {
			break
		}
		for _, d := range dirs {
			nx, ny := cx+d[0], cy+d[1]
			if nx >= 0 && nx < m.height && ny >= 0 && ny < m.width && m.grid[nx][ny] != "#" {
				if !visited[[2]int{nx, ny}] {
					visited[[2]int{nx, ny}] = true
					parent[[2]int{nx, ny}] = [2]int{cx, cy}
					queue = append(queue, [2]int{nx, ny})
				}
			}
		}
	}
	if _, ok := parent[end]; !ok && end != start {
		return nil
	}
	path := [][2]int{}
	cur := end
	for {
		path = append([][2]int{cur}, path...)
		if cur == start {
			break
		}
		cur = parent[cur]
	}
	m.solution = path
	return path
}

func (m *Maze) displaySolution() {
	if m.solution == nil {
		m.solve()
	}
	display := make([][]string, m.height)
	for i := range display {
		display[i] = make([]string, m.width)
		copy(display[i], m.grid[i])
	}
	for _, p := range m.solution[1 : len(m.solution)-1] {
		if display[p[0]][p[1]] != "S" && display[p[0]][p[1]] != "E" {
			display[p[0]][p[1]] = "o"
		}
	}
	for _, row := range display {
		fmt.Println(strings.Join(row, ""))
	}
}

func (m *Maze) save(filename string) error {
	file, err := os.Create(filename)
	if err != nil {
		return err
	}
	defer file.Close()
	for _, row := range m.grid {
		_, err := file.WriteString(strings.Join(row, "") + "\n")
		if err != nil {
			return err
		}
	}
	return nil
}

func (m *Maze) load(filename string) error {
	file, err := os.Open(filename)
	if err != nil {
		return err
	}
	defer file.Close()
	var grid [][]string
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" {
			continue
		}
		grid = append(grid, strings.Split(line, ""))
	}
	if err := scanner.Err(); err != nil {
		return err
	}
	m.grid = grid
	m.height = len(grid)
	m.width = len(grid[0])
	for i := range m.grid {
		for j := range m.grid[i] {
			if m.grid[i][j] == "S" {
				m.start = [2]int{i, j}
			} else if m.grid[i][j] == "E" {
				m.end = [2]int{i, j}
			}
		}
	}
	m.solution = nil
	return nil
}

func main() {
	rand.Seed(time.Now().UnixNano())
	w, h := 21, 21
	if len(os.Args) > 1 {
		w, _ = strconv.Atoi(os.Args[1])
	}
	if len(os.Args) > 2 {
		h, _ = strconv.Atoi(os.Args[2])
	}
	maze := NewMaze(w, h)
	fmt.Println("🧩 Maze Generator")
	fmt.Println("Commands: generate, solve, save <file>, load <file>, quit")
	scanner := bufio.NewScanner(os.Stdin)
	for {
		fmt.Print("> ")
		if !scanner.Scan() {
			break
		}
		parts := strings.Fields(scanner.Text())
		if len(parts) == 0 {
			continue
		}
		switch parts[0] {
		case "quit":
			return
		case "generate":
			maze = NewMaze(w, h)
			maze.display()
		case "solve":
			maze.displaySolution()
		case "save":
			if len(parts) > 1 {
				if err := maze.save(parts[1]); err != nil {
					fmt.Println("Error:", err)
				} else {
					fmt.Printf("Saved to %s\n", parts[1])
				}
			}
		case "load":
			if len(parts) > 1 {
				if err := maze.load(parts[1]); err != nil {
					fmt.Println("Error:", err)
				} else {
					fmt.Printf("Loaded from %s\n", parts[1])
					maze.display()
				}
			}
		default:
			fmt.Println("Unknown command.")
		}
	}
}
