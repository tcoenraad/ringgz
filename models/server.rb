require_relative 'game'

START = 'start'
SERVER_PLACE = 'place'

class Server
  def initialize
    @join_list = { 2 => [], 3 => [], 4 => [] }
    @games = {}
  end

  def join(client, player_count)
    raise 'The player count should be between 2 and 4' unless player_count >= 2 && player_count <= 4

    @join_list[player_count] << client

    if @join_list[player_count].count == player_count
      clients = @join_list[player_count].shuffle
      @join_list[player_count].clear

      setup_game(clients)
    end
  end

  def setup_game(clients)
    x = rand(Board::DIM/2-1..Board::DIM/2+1)
    y = rand(Board::DIM/2-1..Board::DIM/2+1)
    game = Game.new(clients.count, x, y)
    game_id = game.__id__

    @games[game_id] = { :game => game, :clients => clients }

    client_names = clients.map{ |c| c[:name] }
    clients.each do |client|
      client[:socket].puts "#{START} #{client_names.join(' ')} #{x}#{y}"
      client[:game_id] = game_id
    end

    current_client = clients[game.player][:socket]
    current_client.puts SERVER_PLACE
  end

  def place(client, klass, ring, location)
    raise 'You have not joined any game yet -- `join PLAYER_COUNT`' unless client[:game_id]

    game = @games[client[:game_id]]
    current_client = game[:clients][game[:game].player]
    raise 'It is not your turn to place a ring' unless current_client == client

    x = location[0].to_i
    y = location[1].to_i
    game[:game].place_ring(x, y, ring, klass)

    game[:clients].map { |c| c[:socket] }.each do |socket|
      socket.puts "#{SERVER_PLACE} #{klass} #{ring} #{location}"
    end

    current_client = game[:clients][game[:game].player][:socket]
    current_client.puts SERVER_PLACE
  end
end