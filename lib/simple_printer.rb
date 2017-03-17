class SimplePrinter
  def print(board)
    board.each do |x|
      puts x.join('')
    end
    puts
  end
end