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

  attr_accessor :rings
  attr_reader :x
  attr_reader :y

  def initialize x, y, start = false
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
end