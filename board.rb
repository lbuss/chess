require "./piece"
require "./player"

p "what"
# encoding: utf-8

class Board
  # TA: BACK_ROW = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]
  # #setup_board:
  #    BACK_ROW.each_with_idx { |pc, i| pc.new([6, i], :black)}
  #    BACK_ROW.each_with_idx { |pc, i| pc.new([1, i], :white)}
  
  # TA: have a method to set the selector; recompute valid moves yourself.
  
  # TA: avoid attr_accessor unless this really is state that changes.
  attr_accessor :selected, :valid_moves, :current_player
  attr_reader :starting_moves
  
  def initialize
    @board = Array.new(8) {Array.new(8) {nil}}
    @pieces = []
    # TA: starting positions?
    @starting_moves = {
      Bishop => [[2, 0],[5, 0],[2, 7],[5, 7]],
      Rook => [[0, 0],[7, 0],[0, 7],[7, 7]],
      Horse => [[1, 0],[6, 0],[1, 7],[6, 7]],
      Queen => [[4, 0],[4, 7]],
      King => [[3, 0],[3, 7]]
    }
    # TA: why aren't pieces immediately placed on the @board?
    
    @selected = [3,3]
    # TA: make valid_moves a method. Use the @selected variable to calculate.
    @valid_moves = []
    @current_player = :white
  end
  
  def check(color)
    pieces = all_pieces
    king = pieces.find { |piece| piece.is_a?(King) && piece.color == color }
    pieces.each do |piece|
      if piece.color != color
        if piece.valid_moves_neutered.include?(king.pos)
          return true 
        end
      end
    end
    false
  end
  
  def check_mate
    p 'checking your mate'
    pieces = all_pieces
    pieces.each do |piece|
      if piece.color != @current_player
        if !piece.valid_moves.empty?
          return false 
        end
      end
    end
    p "MATE HAS BEEN CHECKED"
    true
  end
  
  def dup_board
    board_dup = Board.new
    all_pieces.each do |piece|
      new_piece = piece.clone
      new_piece.board = board_dup
      board_dup.place_piece(new_piece)
    end
    board_dup
  end
  
  def all_pieces
    piece_array = []
    @board.each do |row|
      row.each do |piece|
        piece_array << piece unless piece.nil?
      end
    end
    piece_array
  end
  
  def player_pieces(color)
    array = []
    all_pieces.each do |piece|
      if piece.color == color 
        array << piece
      end
    end
    array
  end
  
  def print_pieces(array)
    array.each do |piece|
      print piece.pos
      puts
    end
  end
  
  def queening
    [:black, :white].each do |color|
      pawns = player_pieces(color).select { |piece| piece.is_a?(Pawn) }
      pawns.each do |pawn|
        if color == :white
          if pawn.pos[1] == 0
            self[pawn.pos] = Queen.new(pawn.pos, self, color)
          end
        elsif pawn.pos[1] == 7
          self[pawn.pos] = Queen.new(pawn.pos, self, color)
        end
      end
    end
  end
  
  def place_piece(piece)
    @pieces << piece
    self[piece.pos] = piece
  end
  
  def [](position)
    @board[position.last][position.first]
  end
  
  def []=(pos, piece)
    @board[pos.last][pos.first] = piece
  end
  
  def render
    system('clear')
    @board.each_with_index do |row, row_ind|
      row.each_with_index do |piece, col_ind|
        if piece != nil
          display = ''
          if piece.color == :white
            display = 'piece.symbol.blue'
          else
            display = 'piece.symbol.red'
          end
        else
          display = "'   '"
        end
        if @selected == [col_ind, row_ind]
          if @current_player == :white
            display = display + '.bg_cyan'
          else
            display = display + '.bg_magenta'
          end
        elsif @valid_moves.include?([col_ind, row_ind])
          display = display + '.bg_green'
        elsif (row_ind + col_ind) % 2 != 0
          display = display + '.bg_black'
        else
          display = display + '.bg_gray'
        end
        print eval(display)
      end
      puts
    end
  end
end

# "abc".background(:black)
# 
# class String
#   def background(color)
#     val = case color
#     when :black
#       30
#     when :red
#       31
#     when :green
#       32
#     end
#     
#     "\033[#{val}#{self}\033[0m"
#   end
# end

class String
def black;          "\033[30m#{self}\033[0m" end
def red;            "\033[31m#{self}\033[0m" end
def green;          "\033[32m#{self}\033[0m" end
def brown;          "\033[33m#{self}\033[0m" end
def blue;           "\033[34m#{self}\033[0m" end
def magenta;        "\033[35m#{self}\033[0m" end
def cyan;           "\033[36m#{self}\033[0m" end
def gray;           "\033[37m#{self}\033[0m" end
def bg_black;       "\033[40m#{self}\033[0m" end
def bg_red;         "\033[41m#{self}\033[0m" end
def bg_green;       "\033[42m#{self}\033[0m" end
def bg_brown;       "\033[43m#{self}\033[0m" end
def bg_blue;        "\033[44m#{self}\033[0m" end
def bg_magenta;     "\033[45m#{self}\033[0m" end
def bg_cyan;        "\033[46m#{self}\033[0m" end
def bg_gray;        "\033[47m#{self}\033[0m" end
def bold;           "\033[1m#{self}\033[22m" end
def reverse_color;  "\033[7m#{self}\033[27m" end
end

