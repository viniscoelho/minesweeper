require 'spec_helper'
require_relative 'minesweeper'

RSpec.describe Minesweeper, :type => :model do
  it "should successfully initialize width, height and mines" do
    game = Minesweeper.new(10, 15, 20)

    expect(game.width).to eq(10)
    expect(game.height).to eq(15)
    expect(game.mines).to eq(20)
  end

  it "should successfully place all mines" do
    game = Minesweeper.new(10, 15, 20)
    game.initialize_mines
    expect(game.mines_set.size).to eq(20)    
  end

  it "should not expand an expanded cell" do
    game = Minesweeper.new(10, 15, 3)
    game.mines_set.add(game.get_index(0, 1))
    game.mines_set.add(game.get_index(1, 0))
    game.mines_set.add(game.get_index(1, 1))
    game.initialize_graph
    game.play(0, 0)
    expect(game.play(0, 0)).to_not eq(true)
  end

  it "should not place a flag on an expanded cell" do
    game = Minesweeper.new(10, 15, 0)
    game.initialize_graph
    game.play(2, 3)
    expect(game.flag(2, 3)).to_not eq(true)
  end

  it "should not expand a cell having a flag" do
    game = Minesweeper.new(10, 15, 1)
    game.initialize_graph
    game.flag(2, 3)
    expect(game.play(2, 3)).to_not eq(true)
  end

  it "should win the game after expading all cells" do
    game = Minesweeper.new(10, 15, 1)
    game.mines_set.add(game.get_index(2, 3))
    game.initialize_graph
    expect(game.mines_set.size).to eq(1)
    
    game.play(2, 4)
    expect(game.victory?).to eq(true)
  end

  it "should return a index for the corresponding row and column" do
    game = Minesweeper.new(16, 10, 20)
    expect(game.get_index(2, 7)).to eq(39)
  end

  it "should return a pair for the corresponding index" do
    game = Minesweeper.new(16, 10, 20)
    expect(game.get_pair(39)).to eq([2, 7])
  end
end