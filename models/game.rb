require_relative 'board'

class Game
  def initialize(player_count, x = Board::DIM/2-1..Board::DIM/2+1, y = Board::DIM/2-1..Board::DIM/2+1)
    @board = Board.new(x, y)

    @current_player = 0
    @players = []
    if player_count == 2
      @players << [Field::CLASSES[:first], Field::CLASSES[:second]]
      @players << [Field::CLASSES[:third], Field::CLASSES[:fourth]]
    elsif player_count == 3
      @players << [Field::CLASSES[:first], Field::CLASSES[:fourth]]
      @players << [Field::CLASSES[:second], Field::CLASSES[:fourth]]
      @players << [Field::CLASSES[:third], Field::CLASSES[:fourth]]

      @fourth_class_stock = Hash.new { Hash.new }
      Field::RINGS.each do |ring|
        ring = ring[1]
        @fourth_class_stock[ring] = {
          0 => true,
          1 => true,
          2 => true
        }
      end
    elsif player_count == 4
      @players << [Field::CLASSES[:first]]
      @players << [Field::CLASSES[:second]]
      @players << [Field::CLASSES[:third]]
      @players << [Field::CLASSES[:fourth]]
    end
  end

  def player
    @current_player
  end

  def player_count
    @players.count
  end

  def winner?(player)
    winner = false

    # for three players, the fourth class is neutral
    if player_count == 3
      winner ||= @board.winner?(@players[player].first)
    else
      @players[player].each do |klass|
        winner ||= @board.winner?(klass)
      end
    end

    winner
  end

  def place_ring(x, y, ring, klass)
    # for three players, the fourth class is equally shared
    if @player_count == 3 && klass == Field::CLASSES[:fourth]
      if deduct_from_fourth_class_stock?(ring, player)
        deduct_from_fourth_class_stock(ring, player)
      else
        raise "This ring #{ring} with class #{klass} by player #{player} cannot be placed on this game board (x = #{x}, y = #{y})"
      end
    end

    @board[x, y] = [ring, @players[@current_player][klass]]
    next_player
  end

  def next_player
    @current_player += 1
    @current_player = player % player_count
  end

  def deduct_from_fourth_class_stock(ring, klass)
    @fourth_class_stock[ring][klass] = false
  end

  def deduct_from_fourth_class_stock?(ring, klass)
    @fourth_class_stock[ring][klass]
  end 

end