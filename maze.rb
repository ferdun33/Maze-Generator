# maze.rb
require 'set'

class Maze
  attr_reader :grid, :width, :height, :start, :end, :solution

  def initialize(w = 21, h = 21)
    @width = w.even? ? w + 1 : w
    @height = h.even? ? h + 1 : h
    @start = [1, 1]
    @end = [@height - 2, @width - 2]
    @solution = nil
    generate
  end

  def generate
    @grid = Array.new(@height) { Array.new(@width, '#') }
    @grid[1][1] = ' '
    stack = [[1, 1]]
    dirs = [[0, 2], [0, -2], [2, 0], [-2, 0]]
    until stack.empty?
      cx, cy = stack.last
      neighbours = []
      dirs.each do |dx, dy|
        nx, ny = cx + dx, cy + dy
        if nx > 0 && nx < @height - 1 && ny > 0 && ny < @width - 1 && @grid[nx][ny] == '#'
          neighbours << [nx, ny, dx / 2, dy / 2]
        end
      end
      if neighbours.any?
        nx, ny, wx, wy = neighbours.sample
        @grid[cx + wx][cy + wy] = ' '
        @grid[nx][ny] = ' '
        stack << [nx, ny]
      else
        stack.pop
      end
    end
    @grid[@start[0]][@start[1]] = 'S'
    @grid[@end[0]][@end[1]] = 'E'
    @solution = nil
  end

  def display
    @grid.each { |row| puts row.join }
  end

  def solve
    queue = [@start]
    visited = Set.new([@start])
    parent = {}
    dirs = [[0, 1], [0, -1], [1, 0], [-1, 0]]
    until queue.empty?
      cx, cy = queue.shift
      break if [cx, cy] == @end
      dirs.each do |dx, dy|
        nx, ny = cx + dx, cy + dy
        if nx >= 0 && nx < @height && ny >= 0 && ny < @width && @grid[nx][ny] != '#'
          unless visited.include?([nx, ny])
            visited << [nx, ny]
            parent[[nx, ny]] = [cx, cy]
            queue << [nx, ny]
          end
        end
      end
    end
    if parent[[@end[0], @end[1]]].nil? && @end != @start
      @solution = nil
      return nil
    end
    path = []
    cur = @end
    while cur
      path.unshift(cur)
      break if cur == @start
      cur = parent[cur]
    end
    @solution = path
    path
  end

  def display_solution
    solve if @solution.nil?
    display_grid = @grid.map(&:dup)
    @solution[1...-1].each do |x, y|
      display_grid[x][y] = 'o' unless display_grid[x][y] == 'S' || display_grid[x][y] == 'E'
    end
    display_grid.each { |row| puts row.join }
  end

  def save(filename)
    File.open(filename, 'w') do |f|
      @grid.each { |row| f.puts row.join }
    end
  end

  def load(filename)
    lines = File.readlines(filename).map(&:chomp).reject(&:empty?)
    @grid = lines.map(&:chars)
    @height = @grid.size
    @width = @grid[0].size
    @height.times do |i|
      @width.times do |j|
        @start = [i, j] if @grid[i][j] == 'S'
        @end = [i, j] if @grid[i][j] == 'E'
      end
    end
    @solution = nil
  end
end

def main
  w = (ARGV[0] || 21).to_i
  h = (ARGV[1] || 21).to_i
  maze = Maze.new(w, h)
  puts "🧩 Maze Generator"
  puts "Commands: generate, solve, save <file>, load <file>, quit"
  loop do
    print "> "
    parts = gets.chomp.strip.split
    break if parts.empty?
    case parts[0]
    when 'quit'
      break
    when 'generate'
      maze = Maze.new(w, h)
      maze.display
    when 'solve'
      maze.display_solution
    when 'save'
      if parts.size > 1
        maze.save(parts[1])
        puts "Saved to #{parts[1]}"
      end
    when 'load'
      if parts.size > 1
        begin
          maze.load(parts[1])
          puts "Loaded from #{parts[1]}"
          maze.display
        rescue => e
          puts "Error loading file."
        end
      end
    else
      puts "Unknown command."
    end
  end
end

main if __FILE__ == $0
