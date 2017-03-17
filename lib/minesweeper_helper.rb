require 'nokogiri'

class MinesweeperHelper
  attr_reader :width, :height, :mines
  attr_reader :graph, :visited
  attr_reader :mines_set, :mines_around
  attr_reader :remaining, :remaining_flags

  BOARD_FORMAT = {
    unknown_cell: '.',
    clear_cell: ' ',
    bomb: '#',
    flag: 'F'
  }

  NEIGHBOORS = [
    [-1, 0], [1, 0], [0, -1], [0, 1],
    [-1, 1], [1, -1], [-1, -1], [1, 1]
  ]

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

  def save
    new_save = Nokogiri::XML::Builder.new do |xml|
      xml.send(:'minesweeper') {
        xml.send(:'width', @width)
        xml.send(:'height', @height)
        xml.send(:'mines', @mines)
        xml.send(:'minesSet'){
          i = 0
          @mines_set.each do |mine|
            xml.send(:"mine#{i}", mine)
            i += 1
          end
        }
        xml.send(:'minesAround'){
          for mine in 0...@height*@width
            xml.send(:"around#{mine}", @mines_around[mine])
          end
        }
        xml.send(:'graph'){
          for x in 0...@height
            for y in 0...@width
              xml.send(:"from#{get_index(x, y)}"){
                for i in 0...@graph[get_index(x, y)].size
                  xml.send(:"to#{i}", @graph[get_index(x, y)][i])
                end
              }
            end
          end
        }
        
        xml.send(:'visited'){
          for cell in 0...@height*@width
            xml.send(:"cell#{cell}", @visited[cell])
          end
        }
        xml.send(:'remaining', @remaining)
        xml.send(:'remainingFlags', @remainingFlags)
      }
    end
  
    # puts new_save.to_xml
    file = File.new("my_saved_game.xml", "wb")
    file.write(new_save.to_xml)
    file.close
  end
  
  def load(file_name)
    parser = Nokogiri::XML(File.open(file_name))
    # puts parser.to_xml
    main_tag = parser.css('minesweeper')
    @width = main_tag.css('width').text.to_i
    @height = main_tag.css('height').text.to_i
    @mines = main_tag.css('mines').text.to_i

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

    graph_tag = main_tag.css('graph')
    for x in 0...@height*@width
      vertex_tag = graph_tag.css("from#{x}")
      vertex_tag.children.size.times do |y|
        @graph[x] << vertex_tag.css("to#{y}").text.to_i
      end 
    end

    mines_set_tag = main_tag.css('minesSet')
    for cell in 0...@mines
      @mines_set.add(mines_set_tag.css("mine#{cell}").text.to_i)
    end

    mines_around_tag = main_tag.css('minesAround')
    for cell in 0...@height*@width
      @mines_around[cell] = mines_around_tag.css("around#{cell}").text.to_i 
    end

    visited_tag = main_tag.css('visited')
    for cell in 0...@height*@width
      @visited[cell] = visited_tag.css("cell#{cell}").text == "true" ? true : false

      if @visited[cell]
        row, col = get_pair(cell)
        @board[row][col] = get_cell_format(cell)
      end
    end

    @remaining = main_tag.css('remaining').text.to_i
    @remaining_flags = main_tag.css('remainingFlags').text.to_i
  end

end
