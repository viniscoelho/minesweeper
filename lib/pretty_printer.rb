class PrettyPrinter
  def print(board)
    width, height, = board[0].size, board.size

    header = "%10s" % " "
    width.times do |value|
      header += "%3s" % value
    end
    puts header

    height.times do |x|
      row = "%-10s" % x 
      width.times do |y|
        row += "[#{board[x][y]}]"
      end
      puts row
    end
    puts
  end
end