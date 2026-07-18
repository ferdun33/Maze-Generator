# maze.py
import random
import sys
import os
from collections import deque
import time

class Maze:
    def __init__(self, width=21, height=21):
        self.width = width if width % 2 == 1 else width + 1
        self.height = height if height % 2 == 1 else height + 1
        self.grid = []
        self.start = (1, 1)
        self.end = (self.height - 2, self.width - 2)
        self.generate()
        self.solution = []

    def generate(self):
        # Initialize grid with all walls
        self.grid = [['#'] * self.width for _ in range(self.height)]
        # Carve paths using DFS
        stack = [(1, 1)]
        self.grid[1][1] = ' '
        dirs = [(0, 2), (0, -2), (2, 0), (-2, 0)]
        while stack:
            cx, cy = stack[-1]
            neighbours = []
            for dx, dy in dirs:
                nx, ny = cx + dx, cy + dy
                if 0 < nx < self.height and 0 < ny < self.width and self.grid[nx][ny] == '#':
                    neighbours.append((nx, ny, dx//2, dy//2))
            if neighbours:
                nx, ny, wx, wy = random.choice(neighbours)
                self.grid[cx + wx][cy + wy] = ' '
                self.grid[nx][ny] = ' '
                stack.append((nx, ny))
            else:
                stack.pop()
        # Set start and end
        self.grid[self.start[0]][self.start[1]] = 'S'
        self.grid[self.end[0]][self.end[1]] = 'E'

    def display(self):
        for row in self.grid:
            print(''.join(row))

    def solve(self):
        # BFS from start to end
        start = self.start
        end = self.end
        queue = deque([start])
        visited = {start}
        parent = {start: None}
        dirs = [(0, 1), (0, -1), (1, 0), (-1, 0)]
        while queue:
            cx, cy = queue.popleft()
            if (cx, cy) == end:
                break
            for dx, dy in dirs:
                nx, ny = cx + dx, cy + dy
                if 0 <= nx < self.height and 0 <= ny < self.width:
                    if self.grid[nx][ny] != '#' and (nx, ny) not in visited:
                        visited.add((nx, ny))
                        parent[(nx, ny)] = (cx, cy)
                        queue.append((nx, ny))
        # Reconstruct path
        if end not in parent:
            return []
        path = []
        cur = end
        while cur:
            path.append(cur)
            cur = parent[cur]
        path.reverse()
        self.solution = path
        return path

    def display_solution(self):
        if not self.solution:
            self.solve()
        display = [list(row) for row in self.grid]
        for (x, y) in self.solution[1:-1]:
            if display[x][y] not in ('S', 'E'):
                display[x][y] = 'o'
        for row in display:
            print(''.join(row))

    def save(self, filename):
        with open(filename, 'w') as f:
            for row in self.grid:
                f.write(''.join(row) + '\n')

    def load(self, filename):
        with open(filename, 'r') as f:
            self.grid = [list(line.strip()) for line in f if line.strip()]
        self.height = len(self.grid)
        self.width = len(self.grid[0])
        for i in range(self.height):
            for j in range(self.width):
                if self.grid[i][j] == 'S':
                    self.start = (i, j)
                elif self.grid[i][j] == 'E':
                    self.end = (i, j)
        self.solution = []

def main():
    w = int(sys.argv[1]) if len(sys.argv) > 1 else 21
    h = int(sys.argv[2]) if len(sys.argv) > 2 else 21
    maze = Maze(w, h)
    print("🧩 Maze Generator")
    print("Commands: generate, solve, save <file>, load <file>, quit")
    while True:
        cmd = input("> ").strip().split()
        if not cmd:
            continue
        if cmd[0] == 'quit':
            break
        elif cmd[0] == 'generate':
            maze = Maze(w, h)
            maze.display()
        elif cmd[0] == 'solve':
            maze.display_solution()
        elif cmd[0] == 'save' and len(cmd) > 1:
            maze.save(cmd[1])
            print(f"Saved to {cmd[1]}")
        elif cmd[0] == 'load' and len(cmd) > 1:
            maze.load(cmd[1])
            print(f"Loaded from {cmd[1]}")
            maze.display()
        else:
            print("Unknown command.")

if __name__ == "__main__":
    main()
