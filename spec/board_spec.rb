require_relative '../models/board'

describe Board do
  before :each do
    @board = Board.new(2, 2)
  end

  it "will set-up properly" do
    @board[0, 0].should be_an_instance_of Field
    @board[4, 4].should be_an_instance_of Field
    @board[5, 0].should_not be_an_instance_of Field
    @board[0, 5].should_not be_an_instance_of Field
    @board[5, 5].should_not be_an_instance_of Field
  end

  describe "with regard to the rules on placing rings" do
    before :each do
      stub_const("Board::AMOUNT_PER_RING", 5)
      @board = Board.new(2, 2)
    end

    it "will handle multiple different rings, but not twice" do
      @board[2, 1] = [Field::RINGS[:ring_xs], Field::CLASSES[:first]]
      @board[2, 1].should be_an_instance_of Field
      @board[2, 1] = [Field::RINGS[:ring_s], Field::CLASSES[:first]]
      @board[2, 1].should be_an_instance_of Field

      expect {
        @board[2, 1] = [Field::RINGS[:ring_s], Field::CLASSES[:first]]
      }.to raise_error
    end

    it "will after adding a non-solid ring, not accept a solid ring" do
      @board[2, 1] = [Field::RINGS[:ring_xs], Field::CLASSES[:first]]
      expect {
        @board[2, 1] = [Field::RINGS[:solid], Field::CLASSES[:first]]
      }.to raise_error
    end

    it "will after adding a solid ring, not accept any other ring" do
      @board[2, 1] = [Field::RINGS[:solid], Field::CLASSES[:first]]
      expect {
        @board[2, 1] = [Field::RINGS[:ring_xs], Field::CLASSES[:first]]
      }.to raise_error
    end

    it "will not accept any ring if not nearby ring from same class" do
      expect {
        @board[1, 1] = [Field::RINGS[:ring_xs], Field::CLASSES[:first]]
      }.to raise_error
      @board[2, 1] = [Field::RINGS[:ring_xs], Field::CLASSES[:first]]

      expect {
        @board[1, 1] = [Field::RINGS[:ring_xs], Field::CLASSES[:second]]
      }.to raise_error

      @board[1, 1] = [Field::RINGS[:ring_xs], Field::CLASSES[:first]]
    end

    it "will not accept a solid ring if nearby solid rings from same class" do
      @board[2, 1] = [Field::RINGS[:solid], Field::CLASSES[:first]]
      expect {
        @board[1, 1] = [Field::RINGS[:solid], Field::CLASSES[:first]]
      }.to raise_error

      @board[1, 2] = [Field::RINGS[:ring_xs], Field::CLASSES[:second]]
      @board[1, 1] = [Field::RINGS[:solid], Field::CLASSES[:second]]

      expect {
        @board[2, 0] = [Field::RINGS[:solid], Field::CLASSES[:first]]
      }.to raise_error
      @board[2, 0] = [Field::RINGS[:ring_xs], Field::CLASSES[:first]]
      @board[1, 0] = [Field::RINGS[:solid],   Field::CLASSES[:first]]
    end

    it 'will accept a ring on the outer edge' do
      @board[2,3] = [Field::RINGS[:ring_xs], Field::CLASSES[:first]]
      @board[3,3] = [Field::RINGS[:ring_s], Field::CLASSES[:first]]
      @board[3,4] = [Field::RINGS[:ring_m], Field::CLASSES[:first]]
      @board[4,4] = [Field::RINGS[:ring_l], Field::CLASSES[:first]]

      expect {
        @board[4,5] = [Field::RINGS[:solid], Field::CLASSES[:first]]
      }.to raise_error
    end
  end

  describe "with regard to the stock" do
    it "can not give more than three same rings" do
      @board[2, 1] = [Field::RINGS[:ring_xs], Field::CLASSES[:first]]
      @board[1, 1] = [Field::RINGS[:ring_xs],  Field::CLASSES[:first]]
      @board[1, 0] = [Field::RINGS[:ring_xs],  Field::CLASSES[:first]]

      expect {
        @board[0, 0] = [Field::RINGS[:ring_xs], Field::CLASSES[:first]]
      }.to raise_error
      @board[0, 0] = [Field::RINGS[:ring_s],  Field::CLASSES[:first]]
    end
  end

  describe "with regard to gameover" do
    it "is gameover if all rings are used" do
      @board[2, 1] = [Field::RINGS[:ring_xs], Field::CLASSES[:first]]
      @board[2, 1] = [Field::RINGS[:ring_s], Field::CLASSES[:first]]
      @board[2, 1] = [Field::RINGS[:ring_m], Field::CLASSES[:first]]
      @board[2, 1] = [Field::RINGS[:ring_l], Field::CLASSES[:first]]

      @board[1, 1] = [Field::RINGS[:ring_xs], Field::CLASSES[:first]]
      @board[1, 1] = [Field::RINGS[:ring_s], Field::CLASSES[:first]]
      @board[1, 1] = [Field::RINGS[:ring_m], Field::CLASSES[:first]]
      @board[1, 1] = [Field::RINGS[:ring_l], Field::CLASSES[:first]]

      @board[3, 1] = [Field::RINGS[:ring_xs], Field::CLASSES[:first]]
      @board[3, 1] = [Field::RINGS[:ring_s], Field::CLASSES[:first]]
      @board[3, 1] = [Field::RINGS[:ring_m], Field::CLASSES[:first]]
      @board[3, 1] = [Field::RINGS[:ring_l], Field::CLASSES[:first]]

      @board[0, 1] = [Field::RINGS[:solid], Field::CLASSES[:first]]
      @board[1, 2] = [Field::RINGS[:solid], Field::CLASSES[:first]]

      @board.gameover?(Field::CLASSES[:first]).should be_false
      @board[3, 0] = [Field::RINGS[:solid], Field::CLASSES[:first]]
      @board.gameover?(Field::CLASSES[:first]).should be_true
      @board.gameover?(Field::CLASSES[:second]).should be_false
    end
  end
end