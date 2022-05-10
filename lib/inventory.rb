require_relative 'inventories.rb'

class Inventory
  attr_reader :name, :id

  def initialize(data)
    @id = data["id"].to_i
    @name = data["name"]
  end
end