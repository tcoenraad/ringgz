require_relative 'board'

class Field
  SOLID = 0
  RING_XS = 1
  RING_S = 2
  RING_M = 3
  RING_L = 4

  FIRST_CLASS = 0
  SECOND_CLASS = 1
  THIRD_CLASS = 2
  FOURTH_CLASS = 3

  attr_reader :rings
  attr_reader :x
  attr_reader :y

  def initialize board, x, y, start = false
    @board = board
    @rings = {}

    @x = x
    @y = y

    # this mimics a stone allowing all combinations to be made
    if start
      @rings[RING_XS] = FIRST_CLASS
      @rings[RING_S]  = SECOND_CLASS
      @rings[RING_M]  = THIRD_CLASS
      @rings[RING_L]  = FOURTH_CLASS
    end
  end

  def winner?(klass)
    classes = Array.new(4, 0)
    @rings.values.each do |klass|
      classes[klass] += 1
    end

    classes_sorted = classes.sort.reverse
    if classes_sorted.first == classes[klass] && classes_sorted.first != classes_sorted[1]
      return true
    end

    false
  end

  def add_ring(ring, klass)
    neighbouring_classes = neighbours.values.flatten
    neighbouring_rings = neighbours.keys.flatten

    if neighbouring_classes.include?(klass)
      # a solid ring cannot have any inner rings
      # and rings cannot be overwritten
      if !@rings.has_key?(SOLID) && !@rings.has_key?(ring)
        # solid rings cannot be placed
        # if there are yet any other rings on the field
        # or there are solids near
        if ring != SOLID || (@rings.empty? && !neighbouring_rings.include?(SOLID))
          return @rings[ring] = klass
        end
      end
    end

    raise "This type of ring cannot be placed"
  end

  protected
  def neighbours
    neighbours = {}
    neighbours.merge! @board[self.x - 1, self.y].rings unless self.x - 1 < 0
    neighbours.merge! @board[self.x + 1, self.y].rings unless self.x + 1 > Board::DIM
    neighbours.merge! @board[self.x, self.y - 1].rings unless self.y - 1 < 0
    neighbours.merge! @board[self.x, self.y + 1].rings unless self.y + 1 > Board::DIM
    
    neighbours
  end
end