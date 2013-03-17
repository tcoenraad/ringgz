require_relative 'board'

class Game
  PLAYERS = {
    :one   => 0,
    :two   => 1,
    :three => 2,
    :four  => 3
  }

  def initialize(player_count, x = 2, y = 2)
    @board = Board.new(x, y)

    @current_player = 0
    @players = {}
    if player_count == 2
      @players[PLAYERS[:one]] = [Field::CLASSES[:first], Field::CLASSES[:second]]
      @players[PLAYERS[:two]] = [Field::CLASSES[:third], Field::CLASSES[:fourth]]
    elsif player_count == 3
      @players[PLAYERS[:one]]   = [Field::CLASSES[:first], Field::CLASSES[:fourth]]
      @players[PLAYERS[:two]]   = [Field::CLASSES[:second], Field::CLASSES[:fourth]]
      @players[PLAYERS[:three]] = [Field::CLASSES[:third], Field::CLASSES[:fourth]]

      @fourth_class_stock = {}
      Field::RINGS.each_value do |ring|
        @fourth_class_stock[ring] = {
          Field::CLASSES[:first]  => true,
          Field::CLASSES[:second] => true,
          Field::CLASSES[:third]  => true
        }
      end
    elsif player_count == 4
      @players[PLAYERS[:one]]   = [Field::CLASSES[:first]]
      @players[PLAYERS[:two]]   = [Field::CLASSES[:second]]
      @players[PLAYERS[:three]] = [Field::CLASSES[:third]]
      @players[PLAYERS[:four]]  = [Field::CLASSES[:fourth]]
    end
  end

  def player
    @current_player
  end

  def player_count
    @players.count
  end

  def gameover?(player)
    gameover = true

    @players[player].each do |klass|
      gameover &&= @board.gameover?(klass)
    end

    gameover
  end

  def winner
    @players.each_key do |player|
      if winner?(klass)
        return @players.key(klass)
      end
    end

    false
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

    raise "This class #{klass} does not belong to player #{player}" unless @players[@current_player].include?(klass)

    @board[x, y] = [ring, klass]
    next_player
  end

  def next_player
    i = 0
    loop do 
      i += 1
      @current_player += 1
      @current_player = player % player_count
      break unless i < player_count && gameover?(player)
    end

    if i == player_count
      raise "There is no next player that can place a ring, game is over"
    end
  end

  def deduct_from_fourth_class_stock(ring, klass)
    @fourth_class_stock[ring][klass] = false
  end

  def deduct_from_fourth_class_stock?(ring, klass)
    @fourth_class_stock[ring][klass]
  end
end