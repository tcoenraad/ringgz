require_relative 'game'

START = 'start'
SERVER_PLACE = 'place'
NOTIFY = 'notify'
WINNER = 'winner'
SERVER_CHAT = 'chat'

class Server
  def initialize(clients)
    @clients = clients
    @join_list = { 2 => [], 3 => [], 4 => [] }
    @games = {}
  end

  def join(client, player_count)
    raise ServerError, 'The player count should be between 2 and 4' if player_count < 2 || player_count > 4
    @join_list.each_value do |list|
      list.delete(client)
    end

    @join_list[player_count] << client

    if @join_list[player_count].count == player_count
      clients = @join_list[player_count].shuffle
      @join_list[player_count].clear

      x = rand(Board::DIM/2-1..Board::DIM/2+1)
      y = rand(Board::DIM/2-1..Board::DIM/2+1)
      setup_game(clients, x, y)
    end
  end

  def setup_game(clients, x = 2, y = 2)
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
    raise ServerError, 'You have not joined any game yet -- `join PLAYER_COUNT`' unless client[:game_id]

    game = @games[client[:game_id]]
    current_client = game[:clients][game[:game].player]
    raise ServerError, 'It is not your turn to place a ring' unless current_client == client

    x = location[0].to_i
    y = location[1].to_i
    begin
      game[:game].place_ring(x, y, ring, klass)

      game[:clients].map { |c| c[:socket] }.each do |socket|
        socket.puts "#{NOTIFY} #{klass} #{ring} #{location}"
      end

      current_client = game[:clients][game[:game].player][:socket]
      current_client.puts SERVER_PLACE
    rescue GameOverError
      game[:clients].each do |client|
        client[:socket].puts "#{WINNER} #{game[:game].winners.join(' ')}"
        client.delete(:game_id)
      end
      @games.delete(client[:game_id])
    end
  end

  def chat(client, line)
    raise ServerError, 'You have not enabled the chat -- join with `greet PLAYER_NAME 1`' unless client[:chat]
    name = client[:name]
    msg = "#{SERVER_CHAT} #{name} #{line[SERVER_CHAT.length+1..-1]}"

    if !client[:game_id]
      sockets_in_lobby = @clients.map { |c| c[:socket] if !c[:game_id] && c[:chat] }.compact
      sockets_in_lobby.each do |socket|
        socket.puts msg
      end
    else
      sockets_in_game = @games[client[:game_id]][:clients].map { |c| c[:socket] if c[:chat] }.compact
      sockets_in_game.each do |socket|
        socket.puts msg
      end
    end
  end
end

class ServerError < StandardError; end