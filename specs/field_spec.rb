require_relative '../models/field'

describe Field do
  before :each do
    @field = Field.new(Board.new, 1, 2)
  end

  it "has no winner if empty" do
    @field.winner?(Field::CLASSES[:first]).should be_false
  end

  it "has a winner when one ring is placed" do
    @field.place_ring(Field::RINGS[:solid], Field::CLASSES[:first])

    @field.winner?(Field::CLASSES[:first]).should be_true
    @field.winner?(Field::CLASSES[:second]).should be_false
  end

  it "has no winner when two classes are equally divided" do
    @field.place_ring(Field::RINGS[:ring_xs], Field::CLASSES[:first])
    @field.place_ring(Field::RINGS[:ring_s], Field::CLASSES[:first])
    @field.place_ring(Field::RINGS[:ring_m], Field::CLASSES[:second])
    @field.place_ring(Field::RINGS[:ring_l], Field::CLASSES[:second])

    @field.winner?(Field::CLASSES[:first]).should be_false
    @field.winner?(Field::CLASSES[:second]).should be_false
  end

  it "has a winner when two classes are not equally divided" do
    @field.place_ring(Field::RINGS[:ring_xs], Field::CLASSES[:first])
    @field.place_ring(Field::RINGS[:ring_s], Field::CLASSES[:first])
    @field.place_ring(Field::RINGS[:ring_m], Field::CLASSES[:first])
    @field.place_ring(Field::RINGS[:ring_l], Field::CLASSES[:second])

    @field.winner?(Field::CLASSES[:first]).should be_true
    @field.winner?(Field::CLASSES[:second]).should be_false
  end

  it "has a winner when two classes are not equally divided" do
    @field.place_ring(Field::RINGS[:ring_xs], Field::CLASSES[:first])
    @field.place_ring(Field::RINGS[:ring_s], Field::CLASSES[:second])
    @field.place_ring(Field::RINGS[:ring_m], Field::CLASSES[:second])
    @field.place_ring(Field::RINGS[:ring_l], Field::CLASSES[:second])

    @field.winner?(Field::CLASSES[:first]).should be_false
    @field.winner?(Field::CLASSES[:second]).should be_true
  end

  it "has no winner when three classes are equally divided" do
    @field.place_ring(Field::RINGS[:ring_xs], Field::CLASSES[:first])
    @field.place_ring(Field::RINGS[:ring_s], Field::CLASSES[:second])
    @field.place_ring(Field::RINGS[:ring_m], Field::CLASSES[:third])

    @field.winner?(Field::CLASSES[:first]).should be_false
    @field.winner?(Field::CLASSES[:second]).should be_false
    @field.winner?(Field::CLASSES[:third]).should be_false
  end

  it "has a winner when three classes are not equally divided" do
    @field.place_ring(Field::RINGS[:ring_xs], Field::CLASSES[:first])
    @field.place_ring(Field::RINGS[:ring_s], Field::CLASSES[:first])
    @field.place_ring(Field::RINGS[:ring_m], Field::CLASSES[:second])
    @field.place_ring(Field::RINGS[:ring_l], Field::CLASSES[:third])

    @field.winner?(Field::CLASSES[:first]).should be_true
    @field.winner?(Field::CLASSES[:second]).should be_false
    @field.winner?(Field::CLASSES[:third]).should be_false
  end

  it "has a winner when three classes are not equally divided" do
    @field.place_ring(Field::RINGS[:ring_xs], Field::CLASSES[:first])
    @field.place_ring(Field::RINGS[:ring_s], Field::CLASSES[:second])
    @field.place_ring(Field::RINGS[:ring_m], Field::CLASSES[:third])
    @field.place_ring(Field::RINGS[:ring_l], Field::CLASSES[:third])

    @field.winner?(Field::CLASSES[:first]).should be_false
    @field.winner?(Field::CLASSES[:second]).should be_false
    @field.winner?(Field::CLASSES[:third]).should be_true
  end

  it "has no winner when four classes are equally divided" do
    @field.place_ring(Field::RINGS[:ring_xs], Field::CLASSES[:first])
    @field.place_ring(Field::RINGS[:ring_s], Field::CLASSES[:second])
    @field.place_ring(Field::RINGS[:ring_m], Field::CLASSES[:third])
    @field.place_ring(Field::RINGS[:ring_l], Field::CLASSES[:fourth])

    @field.winner?(Field::CLASSES[:first]).should be_false
    @field.winner?(Field::CLASSES[:second]).should be_false
    @field.winner?(Field::CLASSES[:third]).should be_false
    @field.winner?(Field::CLASSES[:fourth]).should be_false
  end
end