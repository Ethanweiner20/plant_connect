require_relative 'dbconnection'
require_relative 'inventory'

class Inventories < DBConnection
  def find(user_id, name: nil)
    # If no name is provided, choose the first inventory
    if name
      sql = <<~SQL
            SELECT * FROM inventories 
            WHERE user_id = $1 AND name = $2
            LIMIT 1
            SQL
      result = query(sql, [user_id, name])
    else
      sql = <<~SQL
            SELECT * FROM inventories 
            WHERE user_id = $1
            LIMIT 1
            SQL
      result = query(sql, [user_id])
    end

    return if result.ntuples == 0

    Inventory.new(result[0])
  end

  def add(user_id, name, is_public: false)
    sql = 'INSERT INTO inventories (name, user_id, is_public) VALUES ($1, $2, $3)'
    query(sql, [name, user_id, is_public])
  end

  def add_plant(plant_id, quantity, inventory_id)
    sql = <<~SQL
          INSERT INTO inventories_plants
            (inventory_id, plant_id, quantity)
          VALUES
            ($1, $2, $3)
          SQL
    query(sql, [inventory_id, plant_id, quantity])
  end

  def update_plant_quantity(plant_id, quantity, inventory_id)
    # Only targets 1 entry <= unique plant_id/inventory_id index
    sql = <<~SQL
          UPDATE inventories_plants
          SET quantity = $1
          WHERE plant_id = $2 AND inventory_id = $3
          SQL
    query(sql, [quantity, plant_id, inventory_id])
  end

  def delete_plant(plant_id, inventory_id)
    # Only targets 1 entry <= unique plant_id/inventory_id index
    sql = <<~SQL
          DELETE FROM inventories_plants
          WHERE plant_id = $1 AND inventory_id = $2
          SQL
    query(sql, [plant_id, inventory_id])
  end
end