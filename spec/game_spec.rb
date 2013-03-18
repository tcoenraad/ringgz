require_relative '../models/game'

describe Game do
  describe 'with regard to two players' do
    before :each do
      @game = Game.new(2)
    end

    it 'does only accept a class when it belongs to the player' do
      @game.place_ring(2, 1, Field::RINGS[:ring_xs], 0)
      expect {
        @game.place_ring(2, 1, Field::RINGS[:ring_s], 1)
      }.to raise_error
      @game.place_ring(2, 1, Field::RINGS[:ring_s], 2)
    end

    it 'loops through the player list' do
      @game.player.should be_equal 0
      @game.place_ring(2, 1, Field::RINGS[:ring_xs], 0)
      @game.player.should be_equal 1
      @game.place_ring(2, 1, Field::RINGS[:ring_s], 2)
      @game.player.should be_equal 0
    end

    it 'gives the right winner at each moment' do
      @game.winners.should eq [0, 1]

      @game.place_ring(2, 1, Field::RINGS[:ring_xs], 0)
      @game.winners.should eq [0]

      @game.place_ring(1, 2, Field::RINGS[:ring_xs], 2)
      @game.winners.should eq [0, 1]

      @game.place_ring(1, 1, Field::RINGS[:ring_xs], 0)
      @game.winners.should eq [0]

      @game.place_ring(3, 2, Field::RINGS[:ring_xs], 2)
      @game.winners.should eq [0, 1]

      @game.place_ring(1, 1, Field::RINGS[:ring_s], 0)
      @game.winners.should eq [1]
    end

    it 'detects a gameover for one player' do
      board = Board.new
      @game.instance_variable_set :@board, board

      board[3, 2] = [Field::RINGS[:solid], Field::CLASSES[:first]]
      board[1, 2] = [Field::RINGS[:solid], Field::CLASSES[:first]]
      board[2, 3] = [Field::RINGS[:solid], Field::CLASSES[:first]]
      board[2, 1] = [Field::RINGS[:ring_xs], Field::CLASSES[:first]]
      board[2, 1] = [Field::RINGS[:ring_s], Field::CLASSES[:first]]
      board[2, 1] = [Field::RINGS[:ring_m], Field::CLASSES[:first]]
      @game.gameover?(0).should be_false
      @game.gameover?(1).should be_false

      board[2, 1] = [Field::RINGS[:ring_l], Field::CLASSES[:first]]
      @game.gameover?(0).should be_false
      @game.gameover?(1).should be_true
    end

    it 'detects a gameover for all players' do
      stub_const("Board::AMOUNT_PER_RING", 1)

      game = Game.new(2)
      game.place_ring(1, 2, Field::RINGS[:ring_xs], 0)
      game.place_ring(2, 1, Field::RINGS[:ring_xs], 2)
      game.place_ring(1, 2, Field::RINGS[:ring_s], 0)
      game.place_ring(2, 1, Field::RINGS[:ring_s], 2)
      game.place_ring(1, 2, Field::RINGS[:ring_m], 0)
      game.place_ring(2, 1, Field::RINGS[:ring_m], 2)
      game.place_ring(1, 2, Field::RINGS[:ring_l], 0)
      game.place_ring(2, 1, Field::RINGS[:ring_l], 2)

      game.gameover?(0).should be_false
      game.gameover?(1).should be_false

      game.place_ring(3, 2, Field::RINGS[:solid], 0)
      expect {
        game.place_ring(2, 3, Field::RINGS[:solid], 2)
      }.to raise_error GameOverError

      game.gameover?(0).should be_true
      game.gameover?(1).should be_true
    end
  end

  describe 'with regard to three players' do
    before :each do
      @game = Game.new(3)
    end

    it 'does only accept a class when it belongs to the player' do
      @game.place_ring(2, 1, Field::RINGS[:ring_xs], 0)
      expect {
        @game.place_ring(2, 1, Field::RINGS[:ring_s], 0)
      }.to raise_error
      @game.place_ring(2, 1, Field::RINGS[:ring_s], 1)
      @game.place_ring(2, 1, Field::RINGS[:ring_m], 3)
    end

    it 'loops through the player list' do
      @game.player.should be_equal 0
      @game.place_ring(2, 1, Field::RINGS[:ring_xs], 0)
      @game.player.should be_equal 1
      @game.place_ring(2, 1, Field::RINGS[:ring_s], 1)
      @game.player.should be_equal 2
      @game.place_ring(2, 1, Field::RINGS[:ring_m], 2)
      @game.player.should be_equal 0
    end

    it 'gives the right winner at each moment' do
      @game.winners.should eq [0, 1, 2]

      @game.place_ring(2, 1, Field::RINGS[:ring_xs], 0)
      @game.winners.should eq [0]

      @game.place_ring(1, 2, Field::RINGS[:ring_xs], 1)
      @game.place_ring(3, 2, Field::RINGS[:ring_xs], 2)
      @game.place_ring(1, 1, Field::RINGS[:ring_xs], 0)
      @game.winners.should eq [0]

      @game.place_ring(2, 1, Field::RINGS[:ring_s], 1)
      @game.winners.should eq [2]

      @game.place_ring(2, 1, Field::RINGS[:ring_m], 2)
      @game.winner?(2).should be_true
    end
  end

  describe 'with regard to four players' do
    before :each do
      @game = Game.new(4)
    end

    it 'does only accept a class when it belongs to the player' do
      @game.place_ring(2, 1, Field::RINGS[:ring_xs], 0)
      expect {
        @game.place_ring(2, 1, Field::RINGS[:ring_s], 0)
      }.to raise_error

      @game.place_ring(2, 1, Field::RINGS[:ring_s], 1)
      expect {
        @game.place_ring(2, 1, Field::RINGS[:ring_l], 3)
      }.to raise_error

      @game.place_ring(2, 1, Field::RINGS[:ring_m], 2)
      @game.place_ring(2, 1, Field::RINGS[:ring_l], 3)
    end

    it 'loops through the player list' do
      @game.place_ring(2, 1, Field::RINGS[:ring_xs], 0)
      @game.player.should be_equal 1
      @game.place_ring(2, 1, Field::RINGS[:ring_s], 1)
      @game.player.should be_equal 2
      @game.place_ring(2, 1, Field::RINGS[:ring_m], 2)
      @game.player.should be_equal 3
      @game.place_ring(2, 1, Field::RINGS[:ring_l], 3)
      @game.player.should be_equal 0
    end

    it 'gives the right winner at each moment' do
      @game.winners.should eq [0, 1, 2, 3]

      @game.place_ring(2, 1, Field::RINGS[:ring_xs], 0)
      @game.winners.should eq [0]

      @game.place_ring(1, 2, Field::RINGS[:ring_xs], 1)
      @game.place_ring(3, 2, Field::RINGS[:ring_xs], 2)
      @game.place_ring(2, 3, Field::RINGS[:ring_xs], 3)
      @game.winners.should eq [0, 1, 2, 3]

      @game.place_ring(1, 1, Field::RINGS[:ring_xs], 0)
      @game.winners.should eq [0]

      @game.place_ring(0, 2, Field::RINGS[:ring_xs], 1)
      @game.winners.should eq [0, 1]
    end
  end
end