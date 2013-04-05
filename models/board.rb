require_relative 'field'

class Board
  DIM = 5
  AMOUNT_PER_RING = 3

  def initialize(x_start, y_start)
    @fields = Array.new(DIM) { |x| Array.new(DIM) { |y| Field.new x, y } }
    @stock = {}

    Field::CLASSES.each_value do |klass|
      default_stock = {}
      Field::RINGS.each_value do |ring|
        default_stock[ring] = AMOUNT_PER_RING
      end

      @stock[klass] = default_stock
    end

    # start ring
    @fields[x_start][y_start] = Field.new x_start, y_start, true
  end

  def stock(klass)
    res = 0
    @stock[klass].each_value do |val|
      res += val
    end

    res
  end

  def won_fields_per_class
    classes = Array.new(4, 0)
    @fields.flatten.each do |field|
      winning_class = field.winner
      if winning_class
        classes[winning_class] += 1
      end
    end
    classes
  end

  def gameover?(klass)
    if stock(klass) > 0
      if a_ring_in_stock_can_be_placed(klass)
        return false
      end
    end

    true
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

    if @fields[x] && deduct_from_stock?(klass, ring)
      field = @fields[x][y]
      if neighbouring_classes(field).include?(klass)
        # a solid ring cannot have any inner rings
        # and rings cannot be overwritten
        if !field.rings.has_key?(Field::RINGS[:solid]) && !field.rings.has_key?(ring)
          # solid rings only be placed
          # if there are not yet any other rings on the field
          # and there are no solids near from the same class
          if ring != Field::RINGS[:solid] || (field.rings.empty? && !neighbouring_solids(field).include?(klass))
            deduct_from_stock(klass, ring)
            return field.rings[ring] = klass
          end
        end
      end
      raise BoardError, "This ring #{ring} with class #{klass} cannot be placed on this field [#{x}, #{y}], with neighbouring classes #{neighbouring_classes(field)} and rings #{neighbouring_rings(field)}"

    end
    raise BoardError, "This ring #{ring} with class #{klass} cannot be placed on this field [#{x}, #{y}]"
  end

  protected
  def neighbouring_rings(field)
    neighbouring_rings = []
    neighbouring_rings << self[field.x - 1, field.y].rings unless field.x - 1 < 0
    neighbouring_rings << self[field.x + 1, field.y].rings unless field.x + 1 >= Board::DIM
    neighbouring_rings << self[field.x, field.y - 1].rings unless field.y - 1 < 0
    neighbouring_rings << self[field.x, field.y + 1].rings unless field.y + 1 >= Board::DIM

    neighbouring_rings.flatten
  end

  def neighbouring_classes(field)
    neighbouring_rings(field).map {|rings| rings.values}.flatten
  end

  def neighbouring_solids(field)
    neighbouring_rings(field).map { |rings| rings[Field::RINGS[:solid]] }
  end

  def deduct_from_stock(klass, ring)
    @stock[klass][ring] -= 1
  end

  def deduct_from_stock?(klass, ring)
    @stock[klass][ring] != 0
  end

  def a_ring_in_stock_can_be_placed(klass)
    res = false
    @stock[klass].each_pair do |ring, value|
      break if res
      if value > 0
        break if res
        @fields.flatten.each do |field|
          res ||= ring_can_be_placed?(field, ring, klass)
        end
      end
    end

    res
  end

  def ring_can_be_placed?(field, ring, klass)
    begin
      self[field.x, field.y] = [ring, klass]
      field.rings.delete(ring)
      @stock[klass][ring] += 1

      return true
    rescue BoardError
      return false
    end
  end
end

class BoardError < StandardError; end