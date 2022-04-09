# Stores the data for a given plant
require_relative 'image_search.rb'

class Plant
  attr_reader :data, :image_src

  def initialize(data)
    @data = data
    @image_src = ImageSearch.find_image_source([data["ScientificName"], data["CommonName"]])
  end

  def [](key)
    data[key].empty? || data[key] == '0' ? nil : data[key]
  end

  def states
    str = data["State"]
    str.index('(') ? str[str.index('(') + 1...str.index(')')] : nil
  end

  # Provides a representative color of the plant
  # Used in various display areas
  def colors
    [data["FlowerColor"], data["FoliageColor"], data["FruitColor"]].reject(&:empty?)
  end
end
