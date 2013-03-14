require_relative 'field'
class Board
  DIM = 5

  def initialize(x_start = 2, y_start = 2)
    @fields = Array.new(DIM) { |x| Array.new(DIM) { |y| Field.new self, x, y } }

    # start ring
    @fields[x_start][y_start] = Field.new self, 2, 2, true
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
      @fields[x][y].add_ring val[0], val[1]
    else
      false
    end
  end
end