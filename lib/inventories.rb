require_relative 'dbconnection'

class Inventories < DBConnection
  def select(user_id, name)
  end

  def add(user_id, name, is_public: false)
    sql = 'INSERT INTO inventories (name, user_id, is_public) VALUES ($1, $2, $3)'
    query(sql, [name, user_id, is_public])
  end

  def add_plant(inventory_id, plant_id)
  end

  def update_plant_quantity(inventory_id, plant_id)
  end
end