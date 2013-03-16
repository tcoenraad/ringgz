require_relative 'field'

class Board
  DIM = 5
  AMOUNT_PER_RING = 3

  def initialize(x_start = DIM/2, y_start = DIM/2)
    @fields = Array.new(DIM) { |x| Array.new(DIM) { |y| Field.new self, x, y } }
    @stock = {}

    Field::CLASSES.each_value do |klass|
      default_stock = {}
      Field::RINGS.each_value do |ring|
        default_stock[ring] = AMOUNT_PER_RING
      end

      @stock[klass] = default_stock
    end

    # start ring
    @fields[x_start][y_start] = Field.new self, 2, 2, true
  end

  def deduct_from_stock(ring, klass)
    @stock[klass][ring] -= 1
  end

  def deduct_from_stock?(ring, klass)
    @stock[klass][ring] != 0
  end

  def stock(klass)
    res = 0
    @stock[klass].each_value do |val|
      res += val
    end

    res
  end

  def winner
    Fields::CLASSES.each_value do |klass|
      if winner?(klass)
        return klass
      end
    end

    false
  end

  def winner?(klass)
    classes = Array.new(4, 0)
    @fields.flatten.each do |field|
      winning_class = field.winner
      if winning_class
        classes[winning_class] += 1
      end
    end

    classes_sorted = classes.sort.reverse
    if classes_sorted.first == classes[klass] && classes_sorted.first != classes_sorted[1]
      return true
    end

    false
  end

  def a_ring_can_be_placed(klass)
    res = false
    @stock[klass].each_pair do |ring, value|
      if value > 0
        @fields.flatten.each do |field|
          res ||= field.place_ring?(ring, klass)
        end
      end
    end

    res
  end

  def gameover?(klass)
    if stock(klass) > 0
      if a_ring_can_be_placed(klass)
        return false
      end
    end

    true
  end

  def gameover
    gameover = true
    Field::CLASSES.each_value do |klass|
      gameover &&=gameover?(klass)
    end

    gameover
  end

  def [](x, y)
    if @fields[x]
      @fields[x][y]
    else
      nil
    end
  end

  def []=(x, y, val)
    ring = val[0]
    klass = val[1]

    if @fields[x] && deduct_from_stock?(ring, klass)
      deduct_from_stock ring, klass
      return @fields[x][y].place_ring ring, klass
    end

    raise "This ring #{ring} with class #{klass} cannot be placed on this board (x = #{x}, y = #{y})"
  end
end