require_relative '../models/server'

describe Server do
  before :each do
    @server = Server.new([])
    @socket = mock
    @socket.stub(:puts).and_return(true)
  end

  it 'will handle join requests' do
    @server.should_receive(:setup_game).exactly(3)

    @server.join('client1', 3)
    @server.join('client2', 3)
    @server.join('client3', 2)
    @server.join('client4', 3)
    @server.join('client5', 3)
    @server.join('client6', 3)
    @server.join('client7', 2)
    @server.join('client8', 3)
  end

  it 'will set-up a game correctly' do
    clients = []
    clients << { :socket => @socket, :name => 'client0' }
    clients << { :socket => @socket, :name => 'client1' }

    clients[0][:socket].should_receive(:puts).exactly(1).with("#{START} client0 client1 22")
    clients[1][:socket].should_receive(:puts).exactly(1).with("#{START} client0 client1 22")
    clients[0][:socket].should_receive(:puts).exactly(1).with("#{SERVER_PLACE}")

    @server.setup_game(clients)
  end

  describe 'with regard to games' do
    before :each do
      @clients = []
      @clients << { :socket => @socket, :name => 'client0' }
      @clients << { :socket => @socket, :name => 'client1', :game_id => 1 }
      @clients << { :socket => @socket, :name => 'client2', :game_id => 1 }
    end

    it 'will let each player place a ring when it is his turn' do
      games = {}
      game_clients = [@clients[1], @clients[2]]
      game = Game.new(2)
      games[1] = { :game => game, :clients => game_clients }

      @server.instance_variable_set(:@games, games)

      @clients[1][:socket].should_receive(:puts).exactly(1).with("#{NOTIFY} 0 1 21")
      @clients[2][:socket].should_receive(:puts).exactly(1).with("#{NOTIFY} 0 1 21")
      @clients[2][:socket].should_receive(:puts).exactly(1).with("#{SERVER_PLACE}")
      @clients[1][:socket].should_receive(:puts).exactly(1).with("#{NOTIFY} 2 2 21")
      @clients[2][:socket].should_receive(:puts).exactly(1).with("#{NOTIFY} 2 2 21")
      @clients[1][:socket].should_receive(:puts).exactly(1).with("#{SERVER_PLACE}")

      expect {
        @server.place(@clients[0], 0, 1, '21')
      }.to raise_error ServerError

      @server.place(@clients[1], 0, 1, '21')
      expect {
        @server.place(@clients[1], 0, 2, '21')
      }.to raise_error ServerError
      @server.place(@clients[2], 2, 2, '21')
    end

    it 'will detect a gameover and give the winners' do
      stub_const("Board::AMOUNT_PER_RING", 1)

      games = {}
      game_clients = [@clients[1], @clients[2]]
      game = Game.new(2)
      games[1] = { :game => game, :clients => game_clients }

      @server.instance_variable_set(:@games, games)

      game.place_ring(1, 2, Field::RINGS[:ring_xs], 0)
      game.place_ring(2, 1, Field::RINGS[:ring_xs], 2)
      game.place_ring(1, 2, Field::RINGS[:ring_s], 0)
      game.place_ring(2, 1, Field::RINGS[:ring_s], 2)
      game.place_ring(1, 2, Field::RINGS[:ring_m], 0)
      game.place_ring(2, 1, Field::RINGS[:ring_m], 2)
      game.place_ring(1, 2, Field::RINGS[:ring_l], 0)
      game.place_ring(2, 1, Field::RINGS[:ring_l], 2)

      @clients[1][:socket].should_receive(:puts).exactly(1).with("#{WINNER} 0 1")
      @clients[2][:socket].should_receive(:puts).exactly(1).with("#{WINNER} 0 1")

      @server.place(@clients[1], 0, Field::RINGS[:solid], '32')
      @server.place(@clients[2], 2, Field::RINGS[:solid], '23')

      expect {
        @server.place(@clients[1], 0, 1, '21')
      }.to raise_error ServerError
    end
  end

  it 'will send chat messages to the right clients' do
    clients = []
    clients << { :socket => @socket, :name => 'client0' }
    clients << { :socket => @socket, :name => 'client1', :chat => true }
    clients << { :socket => @socket, :name => 'client2', :game_id => 1, :chat => true }
    clients << { :socket => @socket, :name => 'client3', :game_id => 1, :chat => true }
    clients << { :socket => @socket, :name => 'client4', :game_id => 2 }
    clients << { :socket => @socket, :name => 'client5', :game_id => 2, :chat => true }

    games = {}
    games[1] = { :clients => [clients[2], clients[3]] }
    games[2] = { :clients => [clients[4], clients[5]] }

    @server.instance_variable_set(:@clients, clients)
    @server.instance_variable_set(:@games, games)

    clients[1][:socket].should_receive(:puts).exactly(1).with("#{SERVER_CHAT} client1 blaat")
    clients[2][:socket].should_receive(:puts).exactly(1).with("#{SERVER_CHAT} client2 blaat")
    clients[3][:socket].should_receive(:puts).exactly(1).with("#{SERVER_CHAT} client2 blaat")
    clients[5][:socket].should_receive(:puts).exactly(1).with("#{SERVER_CHAT} client5 blaat")

    expect {
      @server.chat(clients[0], 'chat blaat')
    }.to raise_error ServerError
    @server.chat(clients[1], 'chat blaat')
    @server.chat(clients[2], 'chat blaat')
    @server.chat(clients[5], 'chat blaat')
  end
end