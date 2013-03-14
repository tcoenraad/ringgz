require_relative '../board'

describe Board do
  before :each do
    @board = Board.new
  end

  it "will set-up properly" do
    @board[0, 0].should be_an_instance_of Field
    @board[4, 4].should be_an_instance_of Field
    @board[5, 0].should_not be_an_instance_of Field
    @board[0, 5].should_not be_an_instance_of Field
    @board[5, 5].should_not be_an_instance_of Field
  end

  it "will handle multiple different rings, but not twice" do
    @board[2, 1] = [Field::RING_XS, Field::FIRST_CLASS]
    @board[2, 1].should be_an_instance_of Field
    @board[2, 1] = [Field::RING_S, Field::FIRST_CLASS]
    @board[2, 1].should be_an_instance_of Field

    expect {
      @board[2, 1] = [Field::RING_S, Field::FIRST_CLASS]
    }.to raise_error
  end

  it "will after adding a non solid ring, not accept a solid ring" do
    @board[2, 1] = [Field::RING_XS, Field::FIRST_CLASS]
    expect {
      @board[2, 1] = [Field::SOLID, Field::FIRST_CLASS]
    }.to raise_error
  end

  it "will after adding a solid ring, not accept any other ring" do
    @board[2, 1] = [Field::SOLID, Field::FIRST_CLASS]
    expect {
      @board[2, 1] = [Field::RING_XS, Field::FIRST_CLASS]
    }.to raise_error
  end

  it "will not accept any ring if not nearby ring from same class" do
    expect {
      @board[1, 1] = [Field::RING_S, Field::FIRST_CLASS]
    }.to raise_error
    @board[2, 1] = [Field::RING_XS, Field::FIRST_CLASS]

    expect {
      @board[1, 1] = [Field::RING_S, Field::SECOND_CLASS]
    }.to raise_error

    @board[1, 1] = [Field::RING_S, Field::FIRST_CLASS]
  end

  it "will not accept a solid ring if nearby any other solid rings" do
    @board[2, 1] = [Field::SOLID, Field::FIRST_CLASS]
    expect {
      @board[1, 1] = [Field::SOLID, Field::FIRST_CLASS]
    }.to raise_error
    expect {
      @board[1, 1] = [Field::SOLID, Field::SECOND_CLASS]
    }.to raise_error

    @board[1, 1] = [Field::RING_XS, Field::FIRST_CLASS]
    @board[1, 0] = [Field::SOLID, Field::FIRST_CLASS]
  end
end