require './lib/simple_printer'
require './lib/pretty_printer'
require './lib/minesweeper'

width, height, num_mines = 11, 20, 50
game = Minesweeper.new(width, height, num_mines)

printer = PrettyPrinter.new
printer.print(game.board_state)

while game.still_playing?
  move = (rand > 0.5) ? 'play' : 'flag'
  col, row, = rand(width), rand(height)

  valid_move = game.flag(col, row) if move == 'flag'
  valid_move = game.play(col, row) if move == 'play'

  puts "#{row}, #{col}"

  if valid_move
    # printer = (rand > 0.5) ? SimplePrinter.new : PrettyPrinter.new
    printer.print(game.board_state)
  end
end

puts "Fim do jogo!"
if game.victory?
  puts "Você venceu!"
  game.board_state(xray: true)
else
  puts "Você perdeu! As minas eram:"
  PrettyPrinter.new.print(game.board_state(xray: true))
end