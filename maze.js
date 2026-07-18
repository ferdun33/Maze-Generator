// maze.js
const fs = require('fs');
const readline = require('readline');

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

class Maze {
    constructor(w = 21, h = 21) {
        this.width = w % 2 === 0 ? w + 1 : w;
        this.height = h % 2 === 0 ? h + 1 : h;
        this.start = [1, 1];
        this.end = [this.height - 2, this.width - 2];
        this.solution = null;
        this.generate();
    }

    generate() {
        this.grid = Array.from({length: this.height}, () => Array(this.width).fill('#'));
        this.grid[1][1] = ' ';
        const stack = [[1, 1]];
        const dirs = [[0, 2], [0, -2], [2, 0], [-2, 0]];
        while (stack.length) {
            const [cx, cy] = stack[stack.length - 1];
            const neighbours = [];
            for (const [dx, dy] of dirs) {
                const nx = cx + dx, ny = cy + dy;
                if (nx > 0 && nx < this.height - 1 && ny > 0 && ny < this.width - 1 && this.grid[nx][ny] === '#') {
                    neighbours.push([nx, ny, dx / 2, dy / 2]);
                }
            }
            if (neighbours.length) {
                const [nx, ny, wx, wy] = neighbours[Math.floor(Math.random() * neighbours.length)];
                this.grid[cx + wx][cy + wy] = ' ';
                this.grid[nx][ny] = ' ';
                stack.push([nx, ny]);
            } else {
                stack.pop();
            }
        }
        this.grid[this.start[0]][this.start[1]] = 'S';
        this.grid[this.end[0]][this.end[1]] = 'E';
        this.solution = null;
    }

    display() {
        console.log(this.grid.map(row => row.join('')).join('\n'));
    }

    solve() {
        const start = this.start, end = this.end;
        const queue = [start];
        const visited = new Set();
        visited.add(start.join(','));
        const parent = new Map();
        const dirs = [[0, 1], [0, -1], [1, 0], [-1, 0]];
        while (queue.length) {
            const [cx, cy] = queue.shift();
            if (cx === end[0] && cy === end[1]) break;
            for (const [dx, dy] of dirs) {
                const nx = cx + dx, ny = cy + dy;
                const key = [nx, ny].join(',');
                if (nx >= 0 && nx < this.height && ny >= 0 && ny < this.width && this.grid[nx][ny] !== '#') {
                    if (!visited.has(key)) {
                        visited.add(key);
                        parent.set(key, [cx, cy]);
                        queue.push([nx, ny]);
                    }
                }
            }
        }
        if (!parent.has(end.join(',')) && end.join(',') !== start.join(',')) {
            this.solution = null;
            return null;
        }
        const path = [];
        let cur = end;
        while (cur) {
            path.unshift(cur);
            if (cur[0] === start[0] && cur[1] === start[1]) break;
            cur = parent.get(cur.join(','));
        }
        this.solution = path;
        return path;
    }

    displaySolution() {
        if (!this.solution) this.solve();
        const display = this.grid.map(row => [...row]);
        for (const [x, y] of this.solution.slice(1, -1)) {
            if (display[x][y] !== 'S' && display[x][y] !== 'E') {
                display[x][y] = 'o';
            }
        }
        console.log(display.map(row => row.join('')).join('\n'));
    }

    save(filename) {
        const content = this.grid.map(row => row.join('')).join('\n');
        fs.writeFileSync(filename, content);
    }

    load(filename) {
        const content = fs.readFileSync(filename, 'utf8');
        const lines = content.split('\n').filter(line => line.trim());
        this.grid = lines.map(line => line.split(''));
        this.height = this.grid.length;
        this.width = this.grid[0].length;
        for (let i = 0; i < this.height; i++) {
            for (let j = 0; j < this.width; j++) {
                if (this.grid[i][j] === 'S') this.start = [i, j];
                else if (this.grid[i][j] === 'E') this.end = [i, j];
            }
        }
        this.solution = null;
    }
}

function ask(question) {
    return new Promise(resolve => rl.question(question, resolve));
}

async function main() {
    const w = parseInt(process.argv[2]) || 21;
    const h = parseInt(process.argv[3]) || 21;
    let maze = new Maze(w, h);
    console.log('🧩 Maze Generator');
    console.log('Commands: generate, solve, save <file>, load <file>, quit');
    while (true) {
        const input = await ask('> ');
        const parts = input.trim().split(/\s+/);
        if (!parts.length) continue;
        switch (parts[0]) {
            case 'quit':
                rl.close();
                return;
            case 'generate':
                maze = new Maze(w, h);
                maze.display();
                break;
            case 'solve':
                maze.displaySolution();
                break;
            case 'save':
                if (parts.length > 1) {
                    maze.save(parts[1]);
                    console.log(`Saved to ${parts[1]}`);
                }
                break;
            case 'load':
                if (parts.length > 1) {
                    try {
                        maze.load(parts[1]);
                        console.log(`Loaded from ${parts[1]}`);
                        maze.display();
                    } catch (e) {
                        console.log('Error loading file.');
                    }
                }
                break;
            default:
                console.log('Unknown command.');
        }
    }
}

main().catch(console.error);
