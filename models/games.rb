require_relative 'game'

class TwoPlayersGame < Game
  def initialize(x, y)
    super(x, y)

    @players[PLAYERS[:one]] = [Field::CLASSES[:first], Field::CLASSES[:second]]
    @players[PLAYERS[:two]] = [Field::CLASSES[:third], Field::CLASSES[:fourth]]
  end
end

class ThreePlayersGame < Game
  def initialize(x, y)
    super(x, y)

    @players[PLAYERS[:one]]   = [Field::CLASSES[:first], Field::CLASSES[:fourth]]
    @players[PLAYERS[:two]]   = [Field::CLASSES[:second], Field::CLASSES[:fourth]]
    @players[PLAYERS[:three]] = [Field::CLASSES[:third], Field::CLASSES[:fourth]]

    @fourth_class_stock = {}
    Field::RINGS.each_value do |ring|
      @fourth_class_stock[ring] = {
        Field::CLASSES[:first]  => true,
        Field::CLASSES[:second] => true,
        Field::CLASSES[:third]  => true
      }
    end
  end

  def place_ring(x, y, ring, klass)
    # for three players, the fourth class is equally shared
    if @players.count == 3 && klass == Field::CLASSES[:fourth]
      if deduct_from_fourth_class_stock?(ring, player)
        deduct_from_fourth_class_stock(ring, player)
      else
        raise "This ring #{ring} with class #{klass} by player #{player} cannot be placed on this game board [#{x}, #{y}]"
      end
    end

    super(x, y, ring, klass)
  end

  def deduct_from_fourth_class_stock(ring, klass)
    @fourth_class_stock[ring][klass] = false
  end

  def deduct_from_fourth_class_stock?(ring, klass)
    @fourth_class_stock[ring][klass]
  end
end

class FourPlayersGame < Game
  def initialize(x, y)
    super(x, y)

    @players[PLAYERS[:one]]   = [Field::CLASSES[:first]]
    @players[PLAYERS[:two]]   = [Field::CLASSES[:second]]
    @players[PLAYERS[:three]] = [Field::CLASSES[:third]]
    @players[PLAYERS[:four]]  = [Field::CLASSES[:fourth]]
  end
end