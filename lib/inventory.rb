require_relative 'inventories.rb'

class Inventory
  attr_reader :name, :id, :num_species, :total_quantity, :username

  def initialize(data)
    @id = data["id"].to_i
    @name = data["name"]
    @num_species = data["num_species"].to_i
    @total_quantity = data["total_quantity"].to_i
    @username = data["username"]
  end
end