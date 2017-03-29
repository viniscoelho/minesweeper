## Description

Minesweeper written in Ruby. For now, the code does not have a GUI (to be added soon).

The player can also **load** and **save** the game, for a later play.

## How to play

Run the script play_minesweeper.rb. You will be asked to either load or not a previously saved game.

Type "sim" to load. Then you will be asked to type the name of the file.
Otherwise, just type "nao".

Next, you will have **three** options to choose:

* **flag**: choose a coordinate (x, y) to place a flag.
* **play**: choose a cell to be expanded.
* **save**: save the current game in a *xml* file.

The game works the same as a regular minesweeper. Once a bomb is revealed, the game ends, as lost.
All bombs position are revealed.

If all non-bomb cells are expanded, the game also ends, as winner.

## Tests

Some quite simple tests where built with RSpec, as a sample.