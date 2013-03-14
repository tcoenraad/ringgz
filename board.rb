require_relative 'field'
class Board
  DIM = 5
  attr_accessor :fields

  def initialize
    @fields = Array.new(DIM) { |x| Array.new(DIM) { |y| Field.new self, x, y } }
    @fields[2][2] = Field.new self, 2, 2, true
  end

  def [](x, y)
    if @fields[x]
      @fields[x][y]
    else
      nil
    end
  end

  def []=(x, y, val)
    if @fields[x]
      @fields[x][y].add_ring val
    else
      false
    end
  end
end