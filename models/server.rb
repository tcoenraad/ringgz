require_relative 'game'

START = 'start'
PLACE = 'place'

class Server
  def initialize
    @join_list = { 2 => [], 3 => [], 4 => [] }
  end

  def join(client, player_count)
    raise 'The player count should be between 2 and 4' unless player_count >= 2 && player_count <= 4

    @join_list[player_count] << client

    if @join_list[player_count].count == player_count
      clients = Array.new(@join_list[player_count])
      @join_list[player_count].clear

      play(clients)
    end
  end

  def play(clients)
    x = rand(Board::DIM/2-1..Board::DIM/2+1)
    y = rand(Board::DIM/2-1..Board::DIM/2+1)
    game = Game.new(clients.count, x, y)

    client_names = clients.map{ |c| c[:name] }
    clients.each do |client|
      client[:socket].puts "#{START} #{client_names.join(' ')} #{x}#{y}"
      client[:game] = game
    end

    current_client = clients[game.player][:socket]
    current_client.puts PLACE
  end
end