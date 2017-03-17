require 'set'

class Minesweeper
  attr_accessor :width, :height, :mines
  attr_accessor :graph, :visited
  attr_accessor :mines_set, :mines_around
  attr_accessor :remaining, :remaining_flags

  BOARD_FORMAT = {
    unknown_cell: '.',
    clear_cell: ' ',
    bomb: '#',
    flag: 'F'
  }

  NEIGHBOORS = [
    [-1, 0], [1, 0], [0, -1], [0, 1],
    [-1, 1], [1, -1], [-1, -1], [1, 1]
  ];

  def initialize(new_width, new_height, new_mines)
    @width            = new_width
    @height           = new_height
    @mines            = new_mines
    @remaining        = @height*@width
    @remaining_flags  = @mines    

    @board        = Array.new(@height) { Array.new(@width) }
    @graph        = Array.new(@height*@width) { Array.new }
    @visited      = Array.new(@height*@width)
    @mines_around = Array.new(@height*@width)
    @mines_set    = Set.new

    @height.times do |x|
      @width.times do |y|
        @board[x][y] = BOARD_FORMAT[:unknown_cell]
        @visited[get_index(x, y)] = false
      end
    end
  end

  def initialize_mines
    @mines.times do |i|
      x, y, = rand(@height), rand(@width)
      redo if @mines_set.member?(get_index(x, y))
      @mines_set.add(get_index(x, y))
    end
  end

  def initialize_graph
    @height.times do |x|
      @width.times do |y|
        next if @mines_set.member?(get_index(x, y))

        mines_found = 0
        NEIGHBOORS.size.times do |idx|
          new_x, new_y, = x + NEIGHBOORS[idx][0], y + NEIGHBOORS[idx][1]
          next if outbounds?(new_x, new_y)

          unless @mines_set.member?(get_index(new_x, new_y))
            @graph[get_index(x, y)] << get_index(new_x, new_y)
          end
          mines_found += 1 if @mines_set.member?(get_index(new_x, new_y))
        end
        @mines_around[get_index(x, y)] = mines_found
      end
    end
  end

  def outbounds?(x, y)
    x < 0 || x >= @height || y < 0 || y >= @width
  end

  def get_cell_format(index)
    @mines_around[index] > 0 ? @mines_around[index] : BOARD_FORMAT[:clear_cell]
  end

  def get_index(row, col)
    row*@width + col
  end

  def get_pair(index)
    [(index/@width).floor, index.modulo(@width)]
  end

  def play(col, row)
    cell = get_index(row, col)
    return false if @visited[cell]
    return false if @board[row][col] == BOARD_FORMAT[:flag]

    if @mines_set.member?(cell)
      @visited[cell] = true
      return false
    end

    bfs = Queue.new
    bfs.push(cell)
    @visited[cell] = true
    @board[row][col] = get_cell_format(cell)
    @remaining -= 1

    while !bfs.empty?
      from = bfs.pop
      next if @mines_around[from] > 0
      
      @graph[from].each do |to|
        next if @visited[to]

        to_x, to_y, = get_pair(to)
        @board[to_x][to_y] = get_cell_format(to)
        @visited[to] = true
        @remaining -= 1
        bfs.push(to)
      end
    end
    true
  end

  def flag(col, row)
    cell = get_index(row, col)
    return false if @visited[cell]
    return false if @remaining_flags == 0

    if @board[row][col] == BOARD_FORMAT[:flag]
      @board[row][col] = BOARD_FORMAT[:unknown_cell]
      @remaining_flags += 1
      true
    else
      @board[row][col] = BOARD_FORMAT[:flag]
      @remaining_flags -= 1
      true
    end
  end

  def still_playing?
    return false if victory?

    @mines_set.each do |cell|
      return false if @visited[cell]
    end
  end

  def victory?
    return @remaining == @mines_set.size
  end

  def board_state(option = nil)
    if !option.nil? && option[:xray]
      @mines_set.each do |cell|
        x, y, = get_pair(cell)
        @board[x][y] = BOARD_FORMAT[:bomb]
      end
    end
    @board
  end

end
