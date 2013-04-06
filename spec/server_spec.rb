require_relative '../models/server'

def socket
  socket = mock
  socket.stub(:puts).and_return(true)
  socket
end

describe Server do
  before :each do
    Server.any_instance.stub(:log)
    @server = Server.new
  end

  it 'will handle join requests' do
    clients = []
    clients << { :socket => socket, :name => 'client0' }
    clients << { :socket => socket, :name => 'client1', :chat => true }
    clients << { :socket => socket, :name => 'client2', :chat => true }
    clients << { :socket => socket, :name => 'client3', :chat => true }
    clients << { :socket => socket, :name => 'client4', :chat => true }

    server = Server.new
    server.instance_variable_set(:@clients, clients)

    clients[0][:socket].should_receive(:puts).exactly(1).with(/#{START} .+ .+ .+/)
    clients[1][:socket].should_receive(:puts).exactly(1).with(/#{START} .+ .+ .+/)
    clients[2][:socket].should_receive(:puts).exactly(1).with(/#{START} .+ .+ .+/)
    clients[3][:socket].should_receive(:puts).exactly(1).with(/#{START} .+ .+ .+/)
    clients[4][:socket].should_receive(:puts).exactly(1).with(/#{START} .+ .+ .+/)

    clients[0][:socket].should_not_receive(:puts).with("#{CHAT_LIST} client0")
    clients[1][:socket].should_not_receive(:puts).with("#{CHAT_LIST} client0")

    clients[1][:socket].should_receive(:puts).exactly(2).with(/#{CHAT_LIST} (client1|client4) (client1|client4)/)
    clients[2][:socket].should_receive(:puts).exactly(1).with(/#{CHAT_LIST} (client2|client3) (client2|client3)/)
 
    server.join(clients[0], 3)
    server.join(clients[1], 3)
    server.join(clients[2], 2)
    server.join(clients[3], 2)
    server.join(clients[4], 3)
  end

  it 'will set-up a game correctly' do
    clients = []
    clients << { :socket => socket, :name => 'client0' }
    clients << { :socket => socket, :name => 'client1' }

    clients[0][:socket].should_receive(:puts).exactly(1).with("#{START} client0 client1 22")
    clients[1][:socket].should_receive(:puts).exactly(1).with("#{START} client0 client1 22")
    clients[0][:socket].should_receive(:puts).exactly(1).with("#{SERVER_PLACE}")

    @server.setup_game(clients, 2, 2)
  end

  describe 'with regard to games' do
    before :each do
      @clients = []
      @clients << { :socket => socket, :name => 'client0', :chat => true }
      @clients << { :socket => socket, :name => 'client1' }
      @clients << { :socket => socket, :name => 'client2', :game_id => 1, :chat => true }
      @clients << { :socket => socket, :name => 'client3', :game_id => 1 }

      @server.instance_variable_set(:@clients, @clients)
    end

    it 'will let each player place a ring when it is his turn' do
      games = {}
      game_clients = [@clients[2], @clients[3]]
      games[1] = { :game => TwoPlayersGame.new(2, 2), :clients => game_clients }

      @server.instance_variable_set(:@games, games)

      @clients[2][:socket].should_receive(:puts).exactly(1).with("#{NOTIFY} client2 21 1 0")
      @clients[3][:socket].should_receive(:puts).exactly(1).with("#{NOTIFY} client2 21 1 0")
      @clients[3][:socket].should_receive(:puts).exactly(1).with("#{SERVER_PLACE}")
      @clients[2][:socket].should_receive(:puts).exactly(1).with("#{NOTIFY} client3 21 2 2")
      @clients[3][:socket].should_receive(:puts).exactly(1).with("#{NOTIFY} client3 21 2 2")
      @clients[2][:socket].should_receive(:puts).exactly(1).with("#{SERVER_PLACE}")

      expect {
        @server.place(@clients[0], '21', 1, 0)
      }.to raise_error ServerError

      @server.place(@clients[2], '21', 1, 0)
      expect {
        @server.place(@clients[2], '21', 2, 0)
      }.to raise_error ServerError
      @server.place(@clients[3], '21', 2, 2)
    end

    it 'will detect a gameover and announce all winners' do
      stub_const("Board::AMOUNT_PER_RING", 1)

      games = {}
      game_clients = [@clients[2], @clients[3]]
      games[1] = { :game => TwoPlayersGame.new(2, 2), :clients => game_clients }

      @server.instance_variable_set(:@games, games)

      @clients[2][:socket].should_receive(:puts).exactly(1).with("#{WINNER} client2 client3")
      @clients[3][:socket].should_receive(:puts).exactly(1).with("#{WINNER} client2 client3")
  
      @clients[0][:socket].should_receive(:puts).exactly(1).with(/#{CHAT_LIST} (client0|client2) (client0|client2)/)
      @clients[2][:socket].should_receive(:puts).exactly(1).with(/#{CHAT_LIST} (client0|client2) (client0|client2)/)

      @server.place(@clients[2], '12', Field::RINGS[:ring_xs], 0)
      @server.place(@clients[3], '21', Field::RINGS[:ring_xs], 2)
      @server.place(@clients[2], '12', Field::RINGS[:ring_s], 0)
      @server.place(@clients[3], '21', Field::RINGS[:ring_s], 2)
      @server.place(@clients[2], '12', Field::RINGS[:ring_m], 0)
      @server.place(@clients[3], '21', Field::RINGS[:ring_m], 2)
      @server.place(@clients[2], '12', Field::RINGS[:ring_l], 0)
      @server.place(@clients[3], '21', Field::RINGS[:ring_l], 2)
      @server.place(@clients[2], '32', Field::RINGS[:solid], 0)
      @server.place(@clients[3], '23', Field::RINGS[:solid], 2)

      expect {
        @server.place(@clients[2], 0, 1, '21')
      }.to raise_error ServerError
    end

    it 'will handle a rage quit' do
      games = {}
      game_clients = [@clients[2], @clients[3]]
      games[1] = { :game => TwoPlayersGame.new(2, 2), :clients => game_clients }

      @server.instance_variable_set(:@games, games)

      @clients[2][:socket].should_receive(:puts).exactly(1).with("#{WINNER}")
      @clients[3][:socket].should_not_receive(:puts).with("#{WINNER}")

      @server.remove_client(@clients[3])
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

    server = Server.new
    server.instance_variable_set(:@clients, clients)
    server.instance_variable_set(:@games, games)

    clients[1][:socket].should_receive(:puts).exactly(1).with("#{SERVER_CHAT} client1 blaat")
    clients[2][:socket].should_receive(:puts).exactly(1).with("#{SERVER_CHAT} client2 blaat")
    clients[3][:socket].should_receive(:puts).exactly(1).with("#{SERVER_CHAT} client2 blaat")
    clients[5][:socket].should_receive(:puts).exactly(1).with("#{SERVER_CHAT} client5 blaat")

    expect {
      server.chat(clients[0], 'chat client0 blaat')
    }.to raise_error ServerError
    server.chat(clients[1], 'chat client1 blaat')
    server.chat(clients[2], 'chat client2 blaat')
    server.chat(clients[5], 'chat client5 blaat')
  end

  describe 'with regard to challenges' do
    before :each do
      @clients = []
      @clients << { :socket => socket, :name => 'client0' }
      @clients << { :socket => socket, :name => 'client1', :challenge => true }
      @clients << { :socket => socket, :name => 'client2', :challenge => true }
      @clients << { :socket => socket, :name => 'client3', :challenge => true }
      @clients << { :socket => socket, :name => 'client4', :challenge => true }

      @server.instance_variable_set(:@clients, @clients)
    end

    it 'can only challenge if all clients do have challenge enabled' do
      expect {
        @server.challenge(@clients[1], "#{SERVER_CHALLENGE} client0 client2")
      }.to raise_error ServerError
    end

    it 'can only challenge others' do
      expect {
        @server.challenge(@clients[1], "#{SERVER_CHALLENGE} client1 client2")
      }.to raise_error ServerError
    end

    it 'can only challenge others that are not challenged yet' do
      @server.challenge(@clients[1], "#{SERVER_CHALLENGE}  client2")

      expect {
        @server.challenge(@clients[3], "#{SERVER_CHALLENGE} client2")
      }.to raise_error ServerError
    end

    it 'can challenge one and revoke the challenge self' do
      @clients[2][:socket].should_receive(:puts).exactly(1).with("#{SERVER_CHALLENGE} client1")

      @clients[1][:socket].should_receive(:puts).exactly(1).with("#{CHALLENGE_RESULT} 0")
      @clients[2][:socket].should_receive(:puts).exactly(1).with("#{CHALLENGE_RESULT} 0")

      @server.challenge(@clients[1], "#{SERVER_CHALLENGE} client2")
      @server.challenge_response(@clients[1], false)
    end

    it 'can challenge two clients and accept' do
      @clients[2][:socket].should_receive(:puts).exactly(1).with("#{SERVER_CHALLENGE} client1 client3")
      @clients[3][:socket].should_receive(:puts).exactly(1).with("#{SERVER_CHALLENGE} client1 client2")

      @clients[1][:socket].should_receive(:puts).exactly(1).with(/#{START} .+ .+ .+/)
      @clients[2][:socket].should_receive(:puts).exactly(1).with(/#{START} .+ .+ .+/)
      @clients[3][:socket].should_receive(:puts).exactly(1).with(/#{START} .+ .+ .+/)

      @clients[1][:socket].should_receive(:puts).exactly(1).with("#{CHALLENGE_RESULT} 1")
      @clients[2][:socket].should_receive(:puts).exactly(1).with("#{CHALLENGE_RESULT} 1")
      @clients[3][:socket].should_receive(:puts).exactly(1).with("#{CHALLENGE_RESULT} 1")

      @server.challenge(@clients[1], "#{SERVER_CHALLENGE} client2 client3")
      @server.challenge_response(@clients[2], true)
      @server.challenge_response(@clients[3], true)
    end

    it 'can challenge three clients and refuse' do
      @clients[2][:socket].should_receive(:puts).exactly(1).with("#{SERVER_CHALLENGE} client1 client3 client4")
      @clients[3][:socket].should_receive(:puts).exactly(1).with("#{SERVER_CHALLENGE} client1 client2 client4")
      @clients[4][:socket].should_receive(:puts).exactly(1).with("#{SERVER_CHALLENGE} client1 client2 client3")

      @clients[1][:socket].should_receive(:puts).exactly(1).with("#{CHALLENGE_RESULT} 0")
      @clients[2][:socket].should_receive(:puts).exactly(1).with("#{CHALLENGE_RESULT} 0")
      @clients[3][:socket].should_receive(:puts).exactly(1).with("#{CHALLENGE_RESULT} 0")
      @clients[4][:socket].should_receive(:puts).exactly(1).with("#{CHALLENGE_RESULT} 0")

      @server.challenge(@clients[1], "#{SERVER_CHALLENGE} client2 client3 client4")
      @server.challenge_response(@clients[2], true)
      @server.challenge_response(@clients[3], true)
      @server.challenge_response(@clients[4], false)
    end
  end
end