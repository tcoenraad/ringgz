require_relative '../models/server'

def socket
  socket = mock
  socket.stub(:puts).and_return(true)
  socket
end

describe Server do
  before :each do
    @server = Server.new([])
  end

  it 'will handle join requests' do
    clients = []
    clients << { :socket => socket, :name => 'client0', :chat => true }
    clients << { :socket => socket, :name => 'client1', :chat => true }
    clients << { :socket => socket, :name => 'client2', :chat => true }
    clients << { :socket => socket, :name => 'client3', :chat => true }
    clients << { :socket => socket, :name => 'client4', :chat => true }
    clients << { :socket => socket, :name => 'client5', :chat => true }
    clients << { :socket => socket, :name => 'client6', :chat => true }
    clients << { :socket => socket, :name => 'client7', :chat => true }

    server = Server.new(clients)

    clients[2][:socket].should_receive(:puts).exactly(1).with("#{CHAT_LEAVE} client0")
    clients[2][:socket].should_receive(:puts).exactly(1).with("#{CHAT_LEAVE} client1")
    clients[2][:socket].should_receive(:puts).exactly(1).with("#{CHAT_LEAVE} client3")
    clients[2][:socket].should_not_receive(:puts).with("#{CHAT_LEAVE} client2")
    clients[2][:socket].should_not_receive(:puts).with("#{CHAT_LEAVE} client4")
    clients[2][:socket].should_not_receive(:puts).with("#{CHAT_LEAVE} client5")
    clients[2][:socket].should_not_receive(:puts).with("#{CHAT_LEAVE} client7")
 
    server.join(clients[0], 3)
    server.join(clients[1], 3)
    server.join(clients[2], 2)
    server.join(clients[3], 3)
    server.join(clients[4], 3)
    server.join(clients[5], 3)
    server.join(clients[6], 2)
    server.join(clients[7], 3)
  end

  it 'will set-up a game correctly' do
    clients = []
    clients << { :socket => socket, :name => 'client0' }
    clients << { :socket => socket, :name => 'client1' }

    clients[0][:socket].should_receive(:puts).exactly(1).with("#{START} client0 client1 22")
    clients[1][:socket].should_receive(:puts).exactly(1).with("#{START} client0 client1 22")
    clients[0][:socket].should_receive(:puts).exactly(1).with("#{SERVER_PLACE}")

    @server.setup_game(clients)
  end

  describe 'with regard to games' do
    before :each do
      @clients = []
      @clients << { :socket => socket, :name => 'client0' }
      @clients << { :socket => socket, :name => 'client1', :game_id => 1 }
      @clients << { :socket => socket, :name => 'client2', :game_id => 1 }
    end

    it 'will let each player place a ring when it is his turn' do
      games = {}
      game_clients = [@clients[1], @clients[2]]
      games[1] = { :game => Game.new(2), :clients => game_clients }

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
      games[1] = { :game => Game.new(2), :clients => game_clients }

      @server.instance_variable_set(:@games, games)

      @clients[1][:socket].should_receive(:puts).exactly(1).with("#{WINNER} 0 1")
      @clients[2][:socket].should_receive(:puts).exactly(1).with("#{WINNER} 0 1")

      @server.place(@clients[1], 0, Field::RINGS[:ring_xs], '12')
      @server.place(@clients[2], 2, Field::RINGS[:ring_xs], '21')
      @server.place(@clients[1], 0, Field::RINGS[:ring_s], '12')
      @server.place(@clients[2], 2, Field::RINGS[:ring_s], '21')
      @server.place(@clients[1], 0, Field::RINGS[:ring_m], '12')
      @server.place(@clients[2], 2, Field::RINGS[:ring_m], '21')
      @server.place(@clients[1], 0, Field::RINGS[:ring_l], '12')
      @server.place(@clients[2], 2, Field::RINGS[:ring_l], '21')
      @server.place(@clients[1], 0, Field::RINGS[:solid], '32')
      @server.place(@clients[2], 2, Field::RINGS[:solid], '23')

      expect {
        @server.place(@clients[1], 0, 1, '21')
      }.to raise_error ServerError
    end
  end

  it 'will send chat messages to the right clients' do
    clients = []
    clients << { :socket => socket, :name => 'client0' }
    clients << { :socket => socket, :name => 'client1', :chat => true }
    clients << { :socket => socket, :name => 'client2', :game_id => 1, :chat => true }
    clients << { :socket => socket, :name => 'client3', :game_id => 1, :chat => true }
    clients << { :socket => socket, :name => 'client4', :game_id => 2 }
    clients << { :socket => socket, :name => 'client5', :game_id => 2, :chat => true }

    games = {}
    games[1] = { :clients => [clients[2], clients[3]] }
    games[2] = { :clients => [clients[4], clients[5]] }

    server = Server.new(clients)
    server.instance_variable_set(:@games, games)

    clients[1][:socket].should_receive(:puts).exactly(1).with("#{SERVER_CHAT} client1 blaat")
    clients[2][:socket].should_receive(:puts).exactly(1).with("#{SERVER_CHAT} client2 blaat")
    clients[3][:socket].should_receive(:puts).exactly(1).with("#{SERVER_CHAT} client2 blaat")
    clients[5][:socket].should_receive(:puts).exactly(1).with("#{SERVER_CHAT} client5 blaat")

    expect {
      server.chat(clients[0], 'chat blaat')
    }.to raise_error ServerError
    server.chat(clients[1], 'chat blaat')
    server.chat(clients[2], 'chat blaat')
    server.chat(clients[5], 'chat blaat')
  end
end