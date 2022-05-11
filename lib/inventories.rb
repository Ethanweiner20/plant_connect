require_relative 'dbconnection'
require_relative 'inventory'

class Inventories < DBConnection
  PAGE_LIMIT = 50

  # rubocop:disable Metrics/MethodLength
  def search_all(inventory_name, owner_name, min_plants, plant_id)
    if plant_id > 0
      plant_id_clause = <<~SQL
                        AND $4 IN (SELECT plant_id FROM inventories_plants
                        WHERE inventory_id = inventories.id)
                        SQL
    end

    sql = <<~SQL
          SELECT inventories.*,
                 count(plant_id) AS num_species,
                 sum(quantity) AS total_quantity,
                 users.username
          FROM inventories
            LEFT OUTER JOIN inventories_plants
            ON inventories.id = inventories_plants.inventory_id
            INNER JOIN users
            ON inventories.user_id = users.id
            WHERE inventories.name ~* $1 AND users.username ~* $2
          GROUP BY inventories.id, users.username
          HAVING count(plant_id) >= $3#{plant_id_clause}
          ORDER BY inventories.created_on DESC;
          SQL

    result = query(sql,
                   [inventory_name, owner_name,
                    min_plants] + (plant_id > 0 ? [plant_id] : []))

    result.map { |tuple| Inventory.new(tuple) }
  end
  # rubocop:enable Metrics/MethodLength

  def find_by_user_id(user_id)
    sql = <<~SQL
          SELECT * FROM inventories#{' '}
          WHERE user_id = $1
          LIMIT 1
          SQL
    result = query(sql, [user_id])

    return if result.ntuples == 0

    Inventory.new(result[0])
  end

  def find_by_id(id)
    sql = <<~SQL
          SELECT * FROM inventories#{' '}
          WHERE id = $1
          LIMIT 1
          SQL
    result = query(sql, [id])

    return if result.ntuples == 0

    Inventory.new(result[0])
  end

  def add(user_id, name, is_public: false)
    sql = <<~SQL
          INSERT INTO inventories
            (name, user_id, is_public)
          VALUES
            ($1, $2, $3)
          SQL
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
