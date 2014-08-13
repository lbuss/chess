# encoding: utf-8


class Piece
  attr_accessor :pos, :color, :board
  
  def initialize(pos, board, color)
    @pos = pos
    @board = board
    @color = color
  end

  def move(pos)
    @board[pos] = self
    @board[@pos] = nil
    # TA: Why?
    @pos = pos.dup
  end
  
  # TA: May want comment explaining method; it returns false if no piece at
  # pos.
  def valid_enemy(move)
    # TA: beware if/else with return true/false. One liner:
    # @board[move] != nil && @board[move].color != @color
    if valid_board(move)  
      if @board[move] != nil && @board[move].color != @color
        return true
      end
    end
    false
  end

  # TA: Does this belong in the Board?
  def valid_board(move)
    if move[0].between?(0,7) && move[1].between?(0,7)
      return true
    end
    false
  end
  
  def valid_friend(move)
    # TA: beware if/else with return true/false. One liner:
    # @board[move] != nil && @board[move].color != @color
    if @board[move] != nil && @board[move].color == @color
      return true
    end
    false
  end
  
  def creates_check(move)
    board_dup = @board.dup_board
    board_dup[@pos].move(move)
    board_dup.check(@color)
  end
  
  def check_checker(array)
    valids = []
    array.each do |move|
      if creates_check(move) == false
        valids << move
      end
    end
    valids
  end
end

class Sliders < Piece
  # TA: do you want the setter method directions=??
  attr_accessor :directions

  def valid_moves
    array = valid_moves_neutered
    check_checker(array)
  end

  def valid_moves_neutered
    moves = []
    directions = self.directions.dup
    directions.each do |dir|
      # TA: what is ans? Not a great name.
      loop_moves = []
      loop do
        if loop_moves.empty?
          check = @pos.combine(dir)
        else
          check = loop_moves.last.combine(dir)
        end
    
        # TA: again, have this method defined elsewhere.
        if ! valid_board(check)
          break
        elsif valid_friend(check)
          break
        elsif valid_enemy(check)
          loop_moves << check
          break
        elsif valid_board(check)
          loop_moves << check
        end
      end
      moves += loop_moves
    end
    moves
  end
end

class Bishop < Sliders
  def initialize(start, board, player)
    @directions = [[1,1],[-1, 1],[-1,-1],[1,-1]]
    super
  end

  def symbol
    return ' B '
  end
end

class Rook < Sliders  
  def initialize(start, board, player)
    @directions = [[1,0],[0, 1],[-1,0],[0,-1]]
    super
  end
  
  def symbol
    return ' R '
  end
end

class Horse < Piece
  # TA: don't need to define initialize then.
  def initialize(start, board, player)
    super
  end
  
  def valid_moves
    array = valid_moves_neutered
    check_checker(array)
  end
  
  def valid_moves_neutered
    moves = []
    [-1,1].each do |ones|
      [-2,2].each do |twos|
        moves << [@pos[0]+twos, @pos[1]+ones]
        moves << [@pos[0]+ones, @pos[1]+twos]
      end
    end
    valid = moves.select{|move| valid_board(move)}
    val = valid.select{|move| @board[move] == nil || @board[move].color != @color}
    val
  end
  
  
  # def valid_moves(moves)
#     array = valid_moves_neutered
#     check_checker(array)
#   end
#   
#   def valid_moves_neutered(moves)
#     # TA: I think you have a method for the filtering..
#     valid = moves.select{|move| move[0].between?(0,7) && move[1].between?(0,7)}
#     # TA: I think you have a method for the filtering..
#     val = valid.select{|move| @board[move] == nil || @board[move].color != @color}
#     # TA: weird. 
#     val
#   end
  
  def symbol
    return ' H '
  end
end

class Queen < Sliders
  def initialize(start, board, player)
    # TA: Spaces after commas.
    # @directions = [
    #   [1, 0], [0, 1]
    #   [-1, 0], [-1, 1],
    #   ...
    # ]
    @directions = [[1,0],[0, 1],[-1,0],[0,-1],[1,1],[-1, 1],[-1,-1],[1,-1]]
    super
  end
  
  def symbol
    return ' Q '
  end
end

class King < Piece
  def initialize(start, board, player)
    super
  end
  
  def valid_moves
    array = valid_moves_neutered
    check_checker(array)
  end
  
  def valid_moves_neutered
    moves = []
    [-1, 0, 1].each do |ones|
      [-1, 0, 1].each do |twos|
        moves << [@pos[0]+twos, @pos[1]+ones]
        moves << [@pos[0]+ones, @pos[1]+twos]
      end
    end
    
    valid = moves.select{|move| valid_board(move)}
    val = valid.select{|move| @board[move] == nil || @board[move].color != @color}
    val
  end
  
  # def valid_moves(moves)
  #   array = valid_moves_neutered
  #   check_checker(array)
  # end
  # 
  # def valid_moves_neutered(moves)
  #   # TA: I think you have a method for the filtering..
  #   valid = moves.select{|move| move[0].between?(0,7) && move[1].between?(0,7)}
  #   # TA: I think you have a method for the filtering..
  #   val = valid.select{|move| @board[move] == nil || @board[move].color != @color}
  #   # TA: weird. 
  #   val
  # end
  
  def symbol
    return ' K '
  end
end

class Pawn < Piece
  def symbol
    return ' P '
  end
  
  def valid_moves
    array = valid_moves_neutered
    check_checker(array)
  end
  
  def valid_moves_neutered
    valids = []
    xmove = [-1,1]
    # TA: use `?` ternary operator.
    if @color == :white
      ymove = [0, -1]
    else
      ymove = [0, 1]
    end
    
    if !valid_enemy(@pos.combine(ymove)) && valid_board(@pos.combine(ymove))
      if ! valid_friend(@pos.combine(ymove))
        valids << @pos.combine(ymove)
      end
    end
    
    xmove.each do |x|
      # TA: try to reduce repetition
      # attack_move = @pos.combine(ymove).combine([x, 0])
      if valid_enemy @pos.combine(ymove).combine([x, 0])
        valids << @pos.combine(ymove).combine([x, 0])
      end
    end
    
    # TA: TODO: jumping on first move.
     
    if @color == :white && @pos[1] == 6
      unless valid_enemy(@pos.combine(ymove))
        unless valid_friend(@pos.combine(ymove))
          unless valid_enemy(@pos.combine(ymove).combine(ymove))
            unless valid_friend(@pos.combine(ymove).combine(ymove))
              valids << @pos.combine(ymove).combine(ymove)
            end
          end
        end
      end
    elsif @color == :black && @pos[1] == 1
      unless valid_enemy(@pos.combine(ymove))
        unless valid_friend(@pos.combine(ymove))
          unless valid_enemy(@pos.combine(ymove).combine(ymove))
            unless valid_friend(@pos.combine(ymove).combine(ymove))
              valids << @pos.combine(ymove).combine(ymove)
            end
          end
        end
      end
    end
    valids
  end
end


class Array
  def combine(array2)
    new_array = []
    new_array << self[0] + array2[0]
    new_array << self[1] + array2[1]
  end
end