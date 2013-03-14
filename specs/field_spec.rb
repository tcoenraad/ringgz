require_relative '../field'

describe Field do
  before :each do
    @field = Field.new(Board.new, 1, 2)
  end

  it "has no winner if empty" do
    @field.winner?(Field::FIRST_CLASS).should be_false
  end

  it "has a winner when one ring is placed" do
    @field.add_ring(Field::SOLID, Field::FIRST_CLASS)

    @field.winner?(Field::FIRST_CLASS).should be_true
    @field.winner?(Field::SECOND_CLASS).should be_false
  end

  it "has no winner when two classes are equally divided" do
    @field.add_ring(Field::RING_XS, Field::FIRST_CLASS)
    @field.add_ring(Field::RING_S, Field::FIRST_CLASS)
    @field.add_ring(Field::RING_M, Field::SECOND_CLASS)
    @field.add_ring(Field::RING_L, Field::SECOND_CLASS)

    @field.winner?(Field::FIRST_CLASS).should be_false
    @field.winner?(Field::SECOND_CLASS).should be_false
  end

  it "has a winner when two classes are not equally divided" do
    @field.add_ring(Field::RING_XS, Field::FIRST_CLASS)
    @field.add_ring(Field::RING_S, Field::FIRST_CLASS)
    @field.add_ring(Field::RING_M, Field::FIRST_CLASS)
    @field.add_ring(Field::RING_L, Field::SECOND_CLASS)

    @field.winner?(Field::FIRST_CLASS).should be_true
    @field.winner?(Field::SECOND_CLASS).should be_false
  end

  it "has a winner when two classes are not equally divided" do
    @field.add_ring(Field::RING_XS, Field::FIRST_CLASS)
    @field.add_ring(Field::RING_S, Field::SECOND_CLASS)
    @field.add_ring(Field::RING_M, Field::SECOND_CLASS)
    @field.add_ring(Field::RING_L, Field::SECOND_CLASS)

    @field.winner?(Field::FIRST_CLASS).should be_false
    @field.winner?(Field::SECOND_CLASS).should be_true
  end

  it "has no winner when three classes are equally divided" do
    @field.add_ring(Field::RING_XS, Field::FIRST_CLASS)
    @field.add_ring(Field::RING_S, Field::SECOND_CLASS)
    @field.add_ring(Field::RING_M, Field::THIRD_CLASS)

    @field.winner?(Field::FIRST_CLASS).should be_false
    @field.winner?(Field::SECOND_CLASS).should be_false
    @field.winner?(Field::THIRD_CLASS).should be_false
  end

  it "has a winner when three classes are not equally divided" do
    @field.add_ring(Field::RING_XS, Field::FIRST_CLASS)
    @field.add_ring(Field::RING_S, Field::FIRST_CLASS)
    @field.add_ring(Field::RING_M, Field::SECOND_CLASS)
    @field.add_ring(Field::RING_L, Field::THIRD_CLASS)

    @field.winner?(Field::FIRST_CLASS).should be_true
    @field.winner?(Field::SECOND_CLASS).should be_false
    @field.winner?(Field::THIRD_CLASS).should be_false
  end

  it "has a winner when three classes are not equally divided" do
    @field.add_ring(Field::RING_XS, Field::FIRST_CLASS)
    @field.add_ring(Field::RING_S, Field::SECOND_CLASS)
    @field.add_ring(Field::RING_M, Field::THIRD_CLASS)
    @field.add_ring(Field::RING_L, Field::THIRD_CLASS)

    @field.winner?(Field::FIRST_CLASS).should be_false
    @field.winner?(Field::SECOND_CLASS).should be_false
    @field.winner?(Field::THIRD_CLASS).should be_true
  end

  it "has no winner when four classes are equally divided" do
    @field.add_ring(Field::RING_XS, Field::FIRST_CLASS)
    @field.add_ring(Field::RING_S, Field::SECOND_CLASS)
    @field.add_ring(Field::RING_M, Field::THIRD_CLASS)
    @field.add_ring(Field::RING_L, Field::FOURTH_CLASS)

    @field.winner?(Field::FIRST_CLASS).should be_false
    @field.winner?(Field::SECOND_CLASS).should be_false
    @field.winner?(Field::THIRD_CLASS).should be_false
    @field.winner?(Field::FOURTH_CLASS).should be_false
  end
end