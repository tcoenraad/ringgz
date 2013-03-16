require_relative '../models/server'

describe Server do
  before :each do
    @server = Server.new
  end

  it 'will handle join requests' do
    @server.stub(:play).and_return(true)
    @server.should_receive(:play).exactly(3)

    @server.join('client1', 3)
    @server.join('client2', 3)
    @server.join('client3', 2)
    @server.join('client4', 3)
    @server.join('client5', 3)
    @server.join('client6', 3)
    @server.join('client7', 2)
    @server.join('client8', 3)
  end
end