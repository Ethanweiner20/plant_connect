class Inventory
  attr_reader :name, :plants

  def initialize(name: nil, plants: [])
    @name = name
    @plants = plants
  end

  def <<(plant)
    plants << plant
  end

  # Filter based on USDA plants
  def filter(_filters)
    []
  end
end
