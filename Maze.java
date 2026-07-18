// Maze.java
import java.io.*;
import java.util.*;

public class Maze {
    private char[][] grid;
    private int width, height;
    private int[] start, end;
    private List<int[]> solution;
    private Random rand = new Random();

    public Maze(int w, int h) {
        width = w % 2 == 0 ? w + 1 : w;
        height = h % 2 == 0 ? h + 1 : h;
        start = new int[]{1, 1};
        end = new int[]{height - 2, width - 2};
        generate();
    }

    private void generate() {
        grid = new char[height][width];
        for (int i = 0; i < height; i++) Arrays.fill(grid[i], '#');
        grid[1][1] = ' ';
        Stack<int[]> stack = new Stack<>();
        stack.push(new int[]{1, 1});
        int[][] dirs = {{0,2},{0,-2},{2,0},{-2,0}};
        while (!stack.isEmpty()) {
            int[] cur = stack.peek();
            int cx = cur[0], cy = cur[1];
            List<int[]> neighbours = new ArrayList<>();
            for (int[] d : dirs) {
                int nx = cx + d[0], ny = cy + d[1];
                if (nx > 0 && nx < height-1 && ny > 0 && ny < width-1 && grid[nx][ny] == '#') {
                    neighbours.add(new int[]{nx, ny, d[0]/2, d[1]/2});
                }
            }
            if (!neighbours.isEmpty()) {
                int[] n = neighbours.get(rand.nextInt(neighbours.size()));
                grid[cx + n[2]][cy + n[3]] = ' ';
                grid[n[0]][n[1]] = ' ';
                stack.push(new int[]{n[0], n[1]});
            } else {
                stack.pop();
            }
        }
        grid[start[0]][start[1]] = 'S';
        grid[end[0]][end[1]] = 'E';
        solution = null;
    }

    public void display() {
        for (char[] row : grid) System.out.println(new String(row));
    }

    public List<int[]> solve() {
        Queue<int[]> queue = new LinkedList<>();
        queue.add(start);
        Set<String> visited = new HashSet<>();
        visited.add(start[0] + "," + start[1]);
        Map<String, int[]> parent = new HashMap<>();
        int[][] dirs = {{0,1},{0,-1},{1,0},{-1,0}};
        while (!queue.isEmpty()) {
            int[] cur = queue.poll();
            int cx = cur[0], cy = cur[1];
            if (cx == end[0] && cy == end[1]) break;
            for (int[] d : dirs) {
                int nx = cx + d[0], ny = cy + d[1];
                if (nx >= 0 && nx < height && ny >= 0 && ny < width && grid[nx][ny] != '#') {
                    String key = nx + "," + ny;
                    if (!visited.contains(key)) {
                        visited.add(key);
                        parent.put(key, cur);
                        queue.add(new int[]{nx, ny});
                    }
                }
            }
        }
        if (!parent.containsKey(end[0] + "," + end[1]) && !(end[0] == start[0] && end[1] == start[1])) {
            solution = null;
            return null;
        }
        List<int[]> path = new ArrayList<>();
        int[] cur = end;
        while (true) {
            path.add(0, cur);
            if (cur[0] == start[0] && cur[1] == start[1]) break;
            cur = parent.get(cur[0] + "," + cur[1]);
        }
        solution = path;
        return path;
    }

    public void displaySolution() {
        if (solution == null) solve();
        char[][] display = new char[height][width];
        for (int i = 0; i < height; i++) System.arraycopy(grid[i], 0, display[i], 0, width);
        for (int i = 1; i < solution.size() - 1; i++) {
            int[] p = solution.get(i);
            if (display[p[0]][p[1]] != 'S' && display[p[0]][p[1]] != 'E') {
                display[p[0]][p[1]] = 'o';
            }
        }
        for (char[] row : display) System.out.println(new String(row));
    }

    public void save(String filename) throws IOException {
        try (PrintWriter pw = new PrintWriter(filename)) {
            for (char[] row : grid) pw.println(new String(row));
        }
    }

    public void load(String filename) throws IOException {
        List<String> lines = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader(filename))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (!line.trim().isEmpty()) lines.add(line);
            }
        }
        height = lines.size();
        width = lines.get(0).length();
        grid = new char[height][width];
        for (int i = 0; i < height; i++) {
            grid[i] = lines.get(i).toCharArray();
            for (int j = 0; j < width; j++) {
                if (grid[i][j] == 'S') start = new int[]{i, j};
                else if (grid[i][j] == 'E') end = new int[]{i, j};
            }
        }
        solution = null;
    }

    public static void main(String[] args) throws Exception {
        int w = 21, h = 21;
        if (args.length > 0) w = Integer.parseInt(args[0]);
        if (args.length > 1) h = Integer.parseInt(args[1]);
        Maze maze = new Maze(w, h);
        Scanner scanner = new Scanner(System.in);
        System.out.println("🧩 Maze Generator");
        System.out.println("Commands: generate, solve, save <file>, load <file>, quit");
        while (true) {
            System.out.print("> ");
            String[] parts = scanner.nextLine().trim().split(" ");
            if (parts.length == 0) continue;
            switch (parts[0]) {
                case "quit": scanner.close(); return;
                case "generate":
                    maze = new Maze(w, h);
                    maze.display();
                    break;
                case "solve":
                    maze.displaySolution();
                    break;
                case "save":
                    if (parts.length > 1) {
                        maze.save(parts[1]);
                        System.out.println("Saved to " + parts[1]);
                    }
                    break;
                case "load":
                    if (parts.length > 1) {
                        try {
                            maze.load(parts[1]);
                            System.out.println("Loaded from " + parts[1]);
                            maze.display();
                        } catch (IOException e) {
                            System.out.println("Error loading file.");
                        }
                    }
                    break;
                default:
                    System.out.println("Unknown command.");
            }
        }
    }
}
