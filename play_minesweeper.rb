Dir[File.dirname(__FILE__) + '/lib/*.rb'].each{|file| require file}
# require './lib/simple_printer'
# require './lib/pretty_printer'
# require './lib/minesweeper'

puts "Carregar jogo?"
move = gets.strip
game = nil

if move == "sim"
  game = Minesweeper.new
  puts "Nome do arquivo: "
  f_name = gets.strip
  game.load(f_name)
else
  width, height, num_mines = 11, 20, 10
  game = Minesweeper.new(width, height, num_mines)
end

printer = PrettyPrinter.new
printer.print(game.board_state)

while game.still_playing?
  puts "Qual movimento deseja fazer?"
  puts "flag: colocar bandeira"
  puts "play: clicar em uma célula"
  puts "save: salvar o jogo"
  move = gets.strip
  game.save if move == 'save'
  redo if move != 'flag' && move != 'play'
  puts "Posição (linha, coluna): "
  x, y, = gets.strip.split(' ')
  x = x.to_i
  y = y.to_i

  valid_move = game.flag(y, x) if move == 'flag'
  valid_move = game.play(y, x) if move == 'play'

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