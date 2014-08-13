require "./piece"
require 'yaml'

class Player
  attr_accessor :color, :selector
  
  def initialize(color, board)
    @color = color
    @board = board
    @selected_piece = nil
    @selector = [4, 4]
    place_pieces
  end
  
  def selector_actions
    begin
      system("stty raw -echo")
      input = STDIN.getc.chr
    ensure
      system("stty -raw echo")
    end
    
    case input 
    when 'l'ks
      ckursor([1, 0])
    when 'j'
      cursor([-1, 0])
    when 'i'
      cursor([0, -1])
    when 'k'
      cursor([0, 1])
    when 's'
      # TA: call board#select!(self.color)
      if @board[@selector] != nil && @board[@selector].color == @color
        display_moves(@board[@selector])
        @selected_piece = @board[@selector]
      elsif @board.valid_moves.include?(@selector)
        # TA: Board#move!(pos). Board knows @curor and @selected.
        @selected_piece.move(@selector)
        @selected_piece = nil
        @board.valid_moves = []
        return true
      else
        puts 'not valid'
        return nil
      end
    when '2'
      contents = File.read("save_file.txt")
      saved_game = YAML::load(contents)
      @board = saved_game
    when '1'
      save_file = @board.to_yaml
      f = File.open("save_file.txt", "w+") do |f|
        f.write(save_file)
        f.close
      end
    when 'q'
      quit
    else
      puts 'invalid entry'
      selector_actions
    end
  end
  
  def cursor(move)
    @selector[0] = (@selector[0] + move.first) % 8
    @selector[1] = (@selector[1] + move.last) % 8
    @board.selected = @selector
  end
  
  # TA: Move me to the board!
  def display_moves(piece)
    moves = piece.valid_moves
    @board.valid_moves = moves
  end

  def place_pieces
    pieces = [Rook, Horse, Bishop, Queen, King, Bishop, Rook, Horse] 
    starting_moves = @board.starting_moves
    pieces.each do |piece|
      starting = starting_moves[piece]
      # starting = klass.class_eval('@@starting_positions').dup
      if @color == :white
        # TA: Not ideal to mutate this object.
        @board.place_piece(piece.new(starting.pop, @board, @color))
      else
        @board.place_piece(piece.new(starting.shift, @board, @color))
      end
    end
    i = 0
    @color == :white ? y = 6 : y = 1
    8.times do 
      @board.place_piece(Pawn.new([i,y], @board, @color))
      i += 1
    end
  end
end

class Computer < Player
  def initialize(color, board)
    @piece_value = {
      'Queen' => 10,
      'Rook' => 6,
      'Horse' => 4,
      'Bishop' => 5,
      'Pawn' => 1,
      'Check' => 9,
    }
    super(color, board)
  end
  
  def selector_actions
    think
  end
end

class DeepBlue < Computer
  
  def think
    sleep(1.0/24.0)
    placement = nil
    random_piece = nil
    until placement != nil && random_piece.valid_board(placement)
      random_piece = @board.player_pieces(@color).sample
      placement = random_piece.valid_moves.sample
    end
    random_piece.move(placement)
    return true
  end
end


class Watson < DeepBlue
  
  def think
    moves = {}
    value = 0
    pieces = @board.player_pieces(@color)
    pieces.each do |piece|
      valids = piece.valid_moves
      valids.each do |move|
        next unless piece.valid_board(move)
        temp_value = 0
        if piece.creates_check(move)
          temp_value += @piece_value['Check']
        end
        if piece.valid_board(move) && piece.valid_enemy(move)
          enemy = @board[move]
          unless @piece_value[enemy.class.name] == nil
            temp_value += @piece_value[enemy.class.name]
          end
        end
        if temp_value > value
          value = temp_value
          moves[piece] = move
        end
      end
    end
    if value == 0
      return super
    end
    p value
    piece_move = moves.keys[0]
    piece_move.move(moves[piece_move])
  end
  
end
      






























    