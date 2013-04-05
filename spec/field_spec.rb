require_relative '../models/field'

describe Field do
  before :each do
    @field = Field.new(1, 2)
  end

  it "has no winner if empty" do
    @field.winner?(Field::CLASSES[:first]).should be_false
  end

  it "has no winner when one solid is placed" do
    @field.rings[Field::RINGS[:solid]] = Field::CLASSES[:first]

    @field.winner?(Field::CLASSES[:first]).should be_false
    @field.winner?(Field::CLASSES[:second]).should be_false
  end

  it "has a winner when one ring is placed" do
    @field.rings[Field::RINGS[:rings_xs]] = Field::CLASSES[:first]

    @field.winner?(Field::CLASSES[:first]).should be_true
    @field.winner?(Field::CLASSES[:second]).should be_false
  end

  it "has no winner when two classes are equally divided" do
    @field.rings[Field::RINGS[:ring_xs]] = Field::CLASSES[:first]
    @field.rings[Field::RINGS[:ring_s]] = Field::CLASSES[:first]
    @field.rings[Field::RINGS[:ring_m]] = Field::CLASSES[:second]
    @field.rings[Field::RINGS[:ring_l]] = Field::CLASSES[:second]

    @field.winner?(Field::CLASSES[:first]).should be_false
    @field.winner?(Field::CLASSES[:second]).should be_false
  end

  it "has a winner when two classes are not equally divided" do
    @field.rings[Field::RINGS[:ring_xs]] = Field::CLASSES[:first]
    @field.rings[Field::RINGS[:ring_s]] = Field::CLASSES[:first]
    @field.rings[Field::RINGS[:ring_m]] = Field::CLASSES[:first]
    @field.rings[Field::RINGS[:ring_l]] = Field::CLASSES[:second]

    @field.winner?(Field::CLASSES[:first]).should be_true
    @field.winner?(Field::CLASSES[:second]).should be_false
  end

  it "has a winner when two classes are not equally divided" do
    @field.rings[Field::RINGS[:ring_xs]] = Field::CLASSES[:first]
    @field.rings[Field::RINGS[:ring_s]] = Field::CLASSES[:second]
    @field.rings[Field::RINGS[:ring_m]] = Field::CLASSES[:second]
    @field.rings[Field::RINGS[:ring_l]] = Field::CLASSES[:second]

    @field.winner?(Field::CLASSES[:first]).should be_false
    @field.winner?(Field::CLASSES[:second]).should be_true
  end

  it "has no winner when three classes are equally divided" do
    @field.rings[Field::RINGS[:ring_xs]] = Field::CLASSES[:first]
    @field.rings[Field::RINGS[:ring_s]] = Field::CLASSES[:second]
    @field.rings[Field::RINGS[:ring_m]] = Field::CLASSES[:third]

    @field.winner?(Field::CLASSES[:first]).should be_false
    @field.winner?(Field::CLASSES[:second]).should be_false
    @field.winner?(Field::CLASSES[:third]).should be_false
  end

  it "has a winner when three classes are not equally divided" do
    @field.rings[Field::RINGS[:ring_xs]] = Field::CLASSES[:first]
    @field.rings[Field::RINGS[:ring_s]] = Field::CLASSES[:first]
    @field.rings[Field::RINGS[:ring_m]] = Field::CLASSES[:second]
    @field.rings[Field::RINGS[:ring_l]] = Field::CLASSES[:third]

    @field.winner?(Field::CLASSES[:first]).should be_true
    @field.winner?(Field::CLASSES[:second]).should be_false
    @field.winner?(Field::CLASSES[:third]).should be_false
  end

  it "has a winner when three classes are not equally divided" do
    @field.rings[Field::RINGS[:ring_xs]] = Field::CLASSES[:first]
    @field.rings[Field::RINGS[:ring_s]] = Field::CLASSES[:second]
    @field.rings[Field::RINGS[:ring_m]] = Field::CLASSES[:third]
    @field.rings[Field::RINGS[:ring_l]] = Field::CLASSES[:third]

    @field.winner?(Field::CLASSES[:first]).should be_false
    @field.winner?(Field::CLASSES[:second]).should be_false
    @field.winner?(Field::CLASSES[:third]).should be_true
  end

  it "has no winner when four classes are equally divided" do
    @field.rings[Field::RINGS[:ring_x]] =  Field::CLASSES[:first]
    @field.rings[Field::RINGS[:ring_s]] = Field::CLASSES[:second]
    @field.rings[Field::RINGS[:ring_m]] = Field::CLASSES[:third]
    @field.rings[Field::RINGS[:ring_l]] = Field::CLASSES[:fourth]

    @field.winner?(Field::CLASSES[:first]).should be_false
    @field.winner?(Field::CLASSES[:second]).should be_false
    @field.winner?(Field::CLASSES[:third]).should be_false
    @field.winner?(Field::CLASSES[:fourth]).should be_false
  end
end