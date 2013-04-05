require_relative 'board'

class Game
  PLAYERS = {
    :one   => 0,
    :two   => 1,
    :three => 2,
    :four  => 3
  }

  def initialize(x = 2, y = 2)
    @board = Board.new(x, y)

    @current_player = 0
    @players = {}
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

  def winners
    winners = []
    @players.each_key do |player|
      if winner?(player)
        winners << player
      end
    end

    return winners unless winners.empty?

    false
  end

  def winner?(player)
    won_fields_per_class = @board.won_fields_per_class

    won_fields = Hash.new(0)
    stock = Hash.new(0)
    @players.each_pair do |player, classes|
      classes.each do |klass|
        # for three players the fourth class is neutral
        next if klass == Field::CLASSES[:fourth] && player_count == 3

        won_fields[player] += won_fields_per_class[klass]
        stock[player] += @board.stock(klass)
      end
    end

    max_won_fields = won_fields.values.max
    winning_players = won_fields.select{ |k, v| v == max_won_fields }.keys
    # a player has won if he has the majority of the fields
    if won_fields[player] == max_won_fields
      # and is the only one
      if winning_players.count == 1
        return true
      # or is the one with the smallest stock
      elsif stock[player] == stock.select{ |k, v| winning_players.include?(k) }.values.min
        return true
      end
    end

    false
  end

  def place_ring(x, y, ring, klass)
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

      break if !gameover?(player) || i > player_count
    end

    if i > player_count
      raise GameOverError, "There is no next player that can place a ring, game is over"
    end
  end
end

class GameOverError < StandardError; end
