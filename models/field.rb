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
    CLASSES.each_value do |klass|
      if winner?(klass)
        return klass
      end
    end

    false
  end

  def winner?(klass)
    # solids are neutral
    if @rings[RINGS[:solid]].nil?
      classes = Array.new(4, 0)
      @rings.values.each do |klass|
        classes[klass] += 1
      end

      classes_sorted = classes.sort.reverse
      if classes_sorted.first == classes[klass] && classes_sorted.first != classes_sorted[1]
        return true
      end
    end

    false
  end

  def place_ring?(ring, klass)
    begin
      place_ring(ring, klass)
      @rings.delete(ring)

      return true
    rescue
      return false
    end
  end

  def place_ring(ring, klass)
    if neighbouring_classes.include?(klass)
      # a solid ring cannot have any inner rings
      # and rings cannot be overwritten
      if !@rings.has_key?(RINGS[:solid]) && !@rings.has_key?(ring)
        # solid rings only be placed
        # if there are not yet any other rings on the field
        # and there are no solids near from the same class
        if ring != RINGS[:solid] || (@rings.empty? && !neighbouring_solids.include?(klass))
          return @rings[ring] = klass
        end
      end
    end

    raise "This ring #{ring} with class #{klass} cannot be placed on this field [#{x}, #{y}], with neighbouring classes #{neighbouring_rings} and rings #{neighbouring_rings}"
  end

  protected
  def neighbouring_rings
    neighbouring_rings = []
    neighbouring_rings << @board[self.x - 1, self.y].rings unless self.x - 1 < 0
    neighbouring_rings << @board[self.x + 1, self.y].rings unless self.x + 1 >= Board::DIM
    neighbouring_rings << @board[self.x, self.y - 1].rings unless self.y - 1 < 0
    neighbouring_rings << @board[self.x, self.y + 1].rings unless self.y + 1 >= Board::DIM

    neighbouring_rings.flatten
  end

  def neighbouring_classes
    neighbouring_rings.map {|rings| rings.values}.flatten
  end

  def neighbouring_solids
    neighbouring_rings.map { |rings| rings[RINGS[:solid]] }
  end
end