require_relative 'protocol'
require_relative 'games'

class Server
  attr_accessor :clients

  def initialize
    @clients = []
    @join_list = { 2 => [], 3 => [], 4 => [] }
    @challenge_list = {}
    @games = {}
  end

  def log(msg)
    puts "[log] #{msg}".blue
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

  def setup_game(clients, x, y)
    case clients.count
    when 2
      game = TwoPlayersGame.new(x, y)
    when 3
      game = ThreePlayersGame.new(x, y)
    when 4
      game = FourPlayersGame.new(x, y)
    end

    game_id = game.__id__
    log "Game ##{game_id} has started! Gamers are: #{clients.map{ |c| c[:name] }.join(', ')}"

    @games[game_id] = { :game => game, :clients => clients }

    player_names = clients.map{ |c| c[:name] }
    clients.each do |client|
      client[:socket].puts "#{Protocol::START} #{player_names.join(' ')} #{x}#{y}"
      client[:game_id] = game_id
    end

    push_game_chat_list(game_id)
    push_lists

    current_client = clients[game.player]
    current_client[:socket].puts Protocol::PLACE

    log "Client ##{current_client[:id]} `#{current_client[:name]}` is next in game ##{game_id}"
  end

  def place(client, location, ring, klass)
    raise ServerError, 'You have not joined any game yet -- `join PLAYER_COUNT`' unless client[:game_id]

    game = game(client[:game_id])
    current_client = game[:clients][game[:game].player]
    raise ServerError, 'It is not your turn to place a ring' unless current_client == client

    x = location[0].to_i
    y = location[1].to_i

    raise ServerError, "The location you gave (#{x}, #{y}) is not valid" if x < 0 || x >= Board::DIM || y < 0 || y >= Board::DIM

    begin
      game[:game].place_ring(x, y, ring, klass)

      game[:clients].each do |game_client|
        game_client[:socket].puts "#{Protocol::NOTIFY} #{client[:name]} #{location} #{ring} #{klass}"
      end

      current_client = game[:clients][game[:game].player]
      current_client[:socket].puts Protocol::PLACE
      
      log "Client ##{current_client[:id]} `#{current_client[:name]}` is next in game ##{current_client[:game_id]}"
    rescue GameOverError
      game_over(game)
    end
  end

  def game_over(game, rage_quit = false)
    log "Game ##{game.__id__} is over!"

    winning_clients = []
    if rage_quit
      log "And it was a rage quit!"
    else
      winning_clients << game[:game].winners.map{|w| game[:clients][w][:name]}
      log "Winners were: #{winning_clients.join(', ')}".strip
    end

    game[:clients].each do |client|
      next unless @clients.include?(client)

      client[:socket].puts "#{Protocol::WINNER} #{winning_clients.join(' ')}".strip
      client.delete(:game_id)
    end

    @games.delete(game[:game].__id__)
    push_lists
  end

  def chat_clients_in_lobby
    @clients.select { |c| !c[:game_id] && c[:chat] }
  end

  def challenge_clients_in_lobby
    @clients.select { |c| !c[:active_challenge] && c[:challenge] }
  end

  def push_lists
    chat_clients_in_lobby.each do |client|
      client[:socket].puts "#{Protocol::CHAT_LIST} #{chat_clients_in_lobby.map{|c| c[:name]}.join(' ')}"
    end

    challenge_clients_in_lobby.each do |client|
      client[:socket].puts "#{Protocol::CHALLENGE_LIST} #{challenge_clients_in_lobby.map{|c| c[:name]}.join(' ')}"
    end
  end

  def push_game_chat_list(game_id)
    chat_clients_in_game = game(game_id)[:clients].select { |c| c[:chat] }
    chat_clients_in_game.each do |client|
      client[:socket].puts "#{Protocol::CHAT_LIST} #{chat_clients_in_game.map { |c| c[:name] }.join(' ')}"
    end
  end

  def chat(client, line)
    raise ServerError, "You have not enabled the chat -- join with `greet PLAYER_NAME #{Protocol::TRUE}`" unless client[:chat]
    name = client[:name]
    msg = "#{Protocol::CHAT} #{name} #{line[Protocol::CHAT.length+1+name.length+1..-1]}"

    chat_clients_near = (client[:game_id]) ? game(client[:game_id])[:clients].select { |c| c[:chat] } : @clients.select { |c| !c[:game_id] && c[:chat] }
    chat_clients_near.each do |client_near|
      client_near[:socket].puts msg
    end
  end

  def challenge(client, line)
    raise ServerError, "You have not enabled challenge -- join with `greet PLAYER_NAME CHAT #{SERVER_TRUES}`" unless client[:challenge]

    challengees = Hash[line[Protocol::CHALLENGE.length+1..-1].split(' ').collect { |v| [v, nil]}]
    raise ServerError, "You can only challenge one to three people" if challengees.count < 1 || challengees.count > 3

    challengees.each_key do |challengee|
      challengee = client(challengee)
      raise ServerError, "You cannot challenge yourself" if challengee == client
      raise ServerError, "You challenged #{client[:name]} who does not support challenges" unless challengee[:challenge]
      raise ServerError, "You challenged #{client[:name]} who already is challenged" if challengee[:active_challenge]
    end

    client[:active_challenge] = client[:name]

    log "A challenge from #{client[:name]} has been requested for #{challengees.keys.join(', ')}"

    challengees.each_key do |challengee|
      challengee_client = client(challengee)
      challengee_client[:active_challenge] = client[:name]
      challengee_client[:socket].puts "#{Protocol::CHALLENGE} #{client[:name]} #{challengees.keys.select{ |c| c != challengee }.join(' ')}".strip
    end

    @challenge_list[client[:name]] = challengees

    push_lists
  end

  def challenge_response(client, response)
    raise ServerError, 'You have have no active challenge -- challenge somewone with `challenge PLAYER_NAME1 PLAYER_NAME2 PLAYER_NAME_3`' unless client[:active_challenge]

    challenge = @challenge_list[client[:active_challenge]]
    if response == Protocol::TRUE
      challenge[client[:name]] = true

      result = true
      challenge.each_value do |challengee_response|
        result &= challengee_response
      end

      return unless result

      msg = "#{Protocol::CHALLENGE_RESULT} #{Protocol::TRUE}"

      clients = challenge.keys.map { |c| client(c) }
      clients << client(client[:active_challenge])
    else
      msg = "#{Protocol::CHALLENGE_RESULT} #{Protocol::FALSE}"
    end

    @challenge_list.delete(client[:active_challenge])
    client(client[:active_challenge])[:socket].puts msg

    challenge.each_key do |challengee|
      challengee_client = client(challengee)
      challengee_client.delete(:active_challenge)
      challengee_client[:socket].puts msg
    end

    if clients
      x = rand(Board::DIM/2-1..Board::DIM/2+1)
      y = rand(Board::DIM/2-1..Board::DIM/2+1)
      setup_game(clients.shuffle, x, y)
    end
  end

  def client(name)
    @clients.each do |client|
      if client[:name] == name
        return client
      end
    end

    raise "Client `#{name}` is not known on this server"
  end

  def remove_client(client)
    @clients.delete(client)

    @join_list.each_value do |list|
      list.delete(client)
    end

    game_over(game(client[:game_id]), true) if client[:game_id]
  end    

  def game(id)
    @games[id]
  end
end

class ServerError < StandardError; end