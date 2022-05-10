require_relative 'inventories.rb'

class Inventory
  attr_reader :name, :id

  def initialize(data)
    @id = data["id"]
    @name = data["name"]
  end
end