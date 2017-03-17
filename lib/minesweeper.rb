require File.expand_path('../minesweeper_helper.rb', __FILE__)

require 'set'

class Minesweeper < MinesweeperHelper

  def initialize(*args)
    if args.size == 3
      @width            = args[0]
      @height           = args[1]
      @mines            = args[2]
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
      initialize_mines
      initialize_graph
    end
  end

  def initialize_mines(default = false)
    if !default
      @mines.times do |i|
        x, y, = rand(@height), rand(@width)
        redo if @mines_set.member?(get_index(x, y))
        @mines_set.add(get_index(x, y))
      end
    else
      sg = SmartGenerator.new(@mines)
      @mines_set = sg.get_mines
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
