🧩 Maze Generator – Multi‑Language Edition
A versatile maze generator and solver that creates random mazes using Depth‑First Search (DFS) with backtracking.
Supports custom dimensions, ASCII visualization, pathfinding (BFS), and export to text files.
Built in 7 programming languages – perfect for learning algorithms, game development, or just having fun!

✨ Features
Random maze generation – uses recursive backtracking (DFS) to create unique mazes every time.

Custom size – specify width and height (default 21×21).

ASCII display – clear visual representation with walls (#) and paths (. or spaces).

Pathfinding – find the shortest path from start (top‑left) to finish (bottom‑right) using BFS.

Animated solving – step‑by‑step path reveal (optional).

Export/Import – save the maze to a text file and load it later.

Multiple algorithms – choose between DFS, Prim’s, or Kruskal’s (optional).

Cross‑platform – works on any terminal (Windows, macOS, Linux).

🗂 Languages & Files
Language	File
Python	maze.py
Go	maze.go
JavaScript (Node)	maze.js
C#	Maze.cs
Java	Maze.java
Ruby	maze.rb
Swift	maze.swift
🚀 How to Run
Each file is standalone – run it with the appropriate interpreter/compiler.

Language	Command
Python	python maze.py [width] [height]
Go	go run maze.go [width] [height]
JavaScript	node maze.js [width] [height]
C#	dotnet run -- [width] [height]
Java	javac Maze.java && java Maze [width] [height]
Ruby	ruby maze.rb [width] [height]
Swift	swift maze.swift [width] [height]
If no dimensions are given, default is 21x21.

🎮 Commands (Interactive)
generate – generate a new random maze.

solve – find and display the shortest path.

save <file> – save the maze to a text file.

load <file> – load a maze from a text file.

quit – exit the program.

📁 Maze File Format
The maze is stored as a simple text file with # for walls, . for paths, S for start, and E for end.

📜 License
MIT – use freely.

