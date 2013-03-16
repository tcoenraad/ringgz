require_relative 'board'

class Field
  RINGS = {
    :solid   => 0,
    :ring_xs => 1,
    :ring_s  => 2,
    :ring_m  => 3,
    :ring_l  => 4,
  }

  CLASSES = {
    :first  => 0,
    :second => 1,
    :third  => 2,
    :fourth => 3
  }

  attr_reader :rings
  attr_reader :x
  attr_reader :y

  def initialize board, x, y, start = false
    @board = board
    @rings = {}

    @x = x
    @y = y

    # this mimics a start stone by allowing all combinations that can be made
    if start
      @rings[RINGS[:ring_xs]] = CLASSES[:first]
      @rings[RINGS[:ring_s]]  = CLASSES[:second]
      @rings[RINGS[:ring_m]]  = CLASSES[:third]
      @rings[RINGS[:ring_l]]  = CLASSES[:fourth]
    end
  end

  def winner
    CLASSES.each do |klass|
      klass = klass[1]
      if winner?(klass)
        return klass
      end
    end

    false
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
        # solid rings cannot be placed
      if !@rings.has_key?(RINGS[:solid]) && !@rings.has_key?(ring)
        # if there are yet any other rings on the field
        # or there are solids near
        if ring != RINGS[:solid] || (@rings.empty? && !neighbouring_rings.include?(RINGS[:solid]))
          return @rings[ring] = klass
        end
      end
    end

    raise "This type of ring cannot be placed"
  end

  protected
  def neighbouring_rings
    neighbouring_rings = []
    neighbouring_rings << @board[self.x - 1, self.y].rings.keys unless self.x - 1 < 0
    neighbouring_rings << @board[self.x + 1, self.y].rings.keys unless self.x + 1 > Board::DIM
    neighbouring_rings << @board[self.x, self.y - 1].rings.keys unless self.y - 1 < 0
    neighbouring_rings << @board[self.x, self.y + 1].rings.keys unless self.y + 1 > Board::DIM

    neighbouring_rings.flatten
  end


  def neighbouring_classes
    neighbouring_classes = []
    neighbouring_classes << @board[self.x - 1, self.y].rings.values unless self.x - 1 < 0
    neighbouring_classes << @board[self.x + 1, self.y].rings.values unless self.x + 1 > Board::DIM
    neighbouring_classes << @board[self.x, self.y - 1].rings.values unless self.y - 1 < 0
    neighbouring_classes << @board[self.x, self.y + 1].rings.values unless self.y + 1 > Board::DIM

    neighbouring_classes.flatten
  end
end