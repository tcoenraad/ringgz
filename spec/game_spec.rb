require_relative '../models/game'

describe Game do
  describe 'with regard to two players' do
    before :each do
      @game = Game.new(2)
    end

    it 'loops through the player list' do
      @game.player.should be_equal 0
      @game.place_ring(2, 1, Field::RINGS[:ring_xs], 0)
      @game.player.should be_equal 1
      @game.place_ring(2, 1, Field::RINGS[:ring_s], 0)
      @game.player.should be_equal 0
    end

    it 'gives the right winner at each moment' do
      @game.winner?(0).should be_false
      @game.winner?(1).should be_false

      @game.place_ring(2, 1, Field::RINGS[:ring_xs], 0)
      @game.winner?(0).should be_true
      @game.winner?(1).should be_false

      @game.place_ring(1, 2, Field::RINGS[:ring_xs], 0)
      @game.winner?(0).should be_false
      @game.winner?(1).should be_false

      @game.place_ring(1, 1, Field::RINGS[:ring_xs], 0)
      @game.winner?(0).should be_true
      @game.winner?(1).should be_false
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
  end

  describe 'with regard to three players' do
    before :each do
      @game = Game.new(3)
    end

    it 'loops through the player list' do
      @game.player.should be_equal 0
      @game.place_ring(2, 1, Field::RINGS[:ring_xs], 0)
      @game.player.should be_equal 1
      @game.place_ring(2, 1, Field::RINGS[:ring_s], 0)
      @game.player.should be_equal 2
      @game.place_ring(2, 1, Field::RINGS[:ring_m], 0)
      @game.player.should be_equal 0
    end

    it 'gives the right winner at each moment' do
      @game.winner?(0).should be_false
      @game.winner?(1).should be_false
      @game.winner?(2).should be_false

      @game.place_ring(2, 1, Field::RINGS[:ring_xs], 0)
      @game.winner?(0).should be_true
      @game.winner?(1).should be_false
      @game.winner?(2).should be_false

      @game.place_ring(1, 2, Field::RINGS[:ring_xs], 0)
      @game.place_ring(3, 2, Field::RINGS[:ring_xs], 0)
      @game.place_ring(1, 1, Field::RINGS[:ring_xs], 0)
      @game.winner?(0).should be_true
      @game.winner?(1).should be_false
      @game.winner?(2).should be_false

      @game.place_ring(2, 1, Field::RINGS[:ring_s], 1)
      @game.winner?(0).should be_false
      @game.winner?(1).should be_false
      @game.winner?(2).should be_false
    end
  end

  describe 'with regard to four players' do
    before :each do
      @game = Game.new(4)
    end

    it 'loops through the player list' do
      @game.player.should be_equal 0
      @game.place_ring(2, 1, Field::RINGS[:ring_xs], 0)
      @game.player.should be_equal 1
      @game.place_ring(2, 1, Field::RINGS[:ring_s], 0)
      @game.player.should be_equal 2
      @game.place_ring(2, 1, Field::RINGS[:ring_m], 0)
      @game.player.should be_equal 3
      @game.place_ring(2, 1, Field::RINGS[:ring_l], 0)
      @game.player.should be_equal 0
    end

    it 'gives the right winner at each moment' do
      @game.winner?(0).should be_false
      @game.winner?(1).should be_false
      @game.winner?(2).should be_false
      @game.winner?(3).should be_false

      @game.place_ring(2, 1, Field::RINGS[:ring_xs], 0)
      @game.winner?(0).should be_true
      @game.winner?(1).should be_false
      @game.winner?(2).should be_false
      @game.winner?(3).should be_false

      @game.place_ring(1, 2, Field::RINGS[:ring_xs], 0)
      @game.place_ring(3, 2, Field::RINGS[:ring_s], 0)
      @game.place_ring(2, 3, Field::RINGS[:ring_m], 0)
      @game.winner?(0).should be_false
      @game.winner?(1).should be_false
      @game.winner?(2).should be_false
      @game.winner?(3).should be_false

      @game.place_ring(1, 1, Field::RINGS[:ring_s], 0)
      @game.winner?(0).should be_true
      @game.winner?(1).should be_false
      @game.winner?(2).should be_false
      @game.winner?(3).should be_false
    end
  end
end