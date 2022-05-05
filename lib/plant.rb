# Stores the data for a given plant
require_relative 'image_search'
require_relative 'plants_storage'

class Plant
  attr_reader :data, :image_src

  def initialize(data)
    @data = data
    @image_src = ImageSearch.find_image_source([data["scientific_name"],
                                                data["common_name"]])
  end

  def [](key)
    return unless data[key]
    data[key].empty? || data[key] == '0' ? nil : data[key]
  end

  def id
    data["id"]
  end

  def states
    str = self["state"]
    return unless str&.index('(')
    str[str.index('(') + 1...str.index(')')]
  end

  # Provides a representative color of the plant
  # Used in various display areas
  def colors
    [self["flower_color"], self["foliage_color"], self["fruit_color"]]
      .compact.reject(&:empty?)
  end
end

class InventoryPlant < Plant
  attr_reader :id, :quantity

  def initialize(id, plants_storage, quantity: 0, data: nil)
    data ||= plants_storage.find_by_id(id).data
    @id = id
    super(data)
    @quantity = quantity
  end
end
