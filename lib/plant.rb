# Stores the data for a given plant
require_relative 'image_search.rb'

class Plant
  attr_reader :data, :image_src

  def initialize(data)
    @data = data
    @image_src = ImageSearch.find_image_source([data["ScientificName"], data["CommonName"]])
  end

  def [](key)
    data[key]
  end

  # Provides a representative color of the plant
  # Used in various display areas
  def color; end
end
