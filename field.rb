class Field
  SOLID = 0
  RING_XS = 1
  RING_S = 2
  RING_M = 3
  RING_L = 4

  FIRST_CLASS = 0
  SECOND_CLASS = 1
  THIRD_CLASS = 3
  FOURTH_CLASS = 4

  attr_reader :x
  attr_reader :y

  def initialize board, x, y, start = false
    @board = board
    @rings = {}

    @x = x
    @y = y

    if start
      @rings[RING_XS] = FIRST_CLASS
      @rings[RING_S] = SECOND_CLASS
      @rings[RING_M] = THIRD_CLASS
      @rings[RING_L] = FOURTH_CLASS
    end
  end

  def add_ring(pair)
    ring  = pair[0]
    klass = pair[1]

    if neighbours?(klass)
      # a solid ring cannot have any inner rings
      # && rings cannot be overwritten
      if !@rings.has_key?(SOLID) && !@rings.has_key?(ring)
        # solid rings cannot be placed
        # if there are yet any other rings
        unless ring == SOLID && !@rings.empty?
          return @rings[ring] = klass
        end
      end
    end

    raise "This type of ring cannot be placed"
  end

  protected
  def classes
    classes = []
    @rings.each do |klass|
      classes << klass
    end
    classes
  end

  def neighbours?(klass)
    neighbouring_classes = []
    neighbouring_classes << @board[self.x - 1, self.y].classes unless self.x - 1 < 0
    neighbouring_classes << @board[self.x + 1, self.y].classes unless self.x + 1 > Board::DIM
    neighbouring_classes << @board[self.x, self.y - 1].classes unless self.y - 1 < 0
    neighbouring_classes << @board[self.x, self.y + 1].classes unless self.y + 1 > Board::DIM
    neighbouring_classes.flatten.include?(klass)
  end

  def inspect
    @rings
  end
end