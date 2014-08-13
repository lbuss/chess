require "./board"
require "./player"

class Game
  attr_reader :board
  
  def initialize
    @board = Board.new
    @player1 = Player.new(:white, @board)
    @player2 = Player.new(:black, @board)
  end
  
  def run
    @board.render
    loop do
      turn(@player1)
      @board.queening
      break if @board.check_mate == true
      turn(@player2)
      @board.queening
      break if @board.check_mate == true
    end
  end
  
  def turn(player)
    #could be method in board
    @board.current_player = player.color
    @board.selected = player.selector
    @board.render
    moved = nil
    until moved == true  
      moved = player.selector_actions
      @board.render
      if @board.check((player.color == :white ? :black : :white))
        puts "CHECKED"
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  chess = Game.new
  chess.run
end

#implement learning TODO