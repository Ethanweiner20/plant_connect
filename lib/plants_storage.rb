require 'pg'
require_relative 'plant'
require_relative 'dbconnection'

class NoPlantFoundError < StandardError
  def initialize(msg="No plant found.")
    super(msg)
  end
end

class PlantsStorage < DBConnection
  PAGE_LIMIT = 6

  NUMERICAL_FILTERS = %w(precipitation_minimum
                         precipitation_maximum
                         temperature_minimum)


  def perform_search_query(filters, offset, limit, inventory_id, inventory_only)
    if inventory_only # Search inventory only
      conditions, params = filters_to_conditions(filters, 4)

      sql = <<~SQL
      SELECT plants.id AS pid, *
      FROM plants
        INNER JOIN inventories_plants
        ON plants.id = inventories_plants.plant_id
        WHERE inventory_id = $3 #{conditions.length > 0 ? 'AND' : ''} #{conditions}
      ORDER BY scientific_name
      LIMIT $1
      OFFSET $2;
      SQL

      result = query(sql, [limit, offset, inventory_id] + params)
    elsif inventory_id # Search all with inventory mixed in
      conditions, params = filters_to_conditions(filters, 4)

      sql = <<~SQL
      SELECT plants.id AS pid, *
      FROM plants
        LEFT OUTER JOIN
        (SELECT * FROM inventories_plants WHERE inventory_id = $3) AS inventory_plants
        ON plants.id = inventory_plants.plant_id
        #{conditions.length > 0 ? 'WHERE' : ''} #{conditions} 
      ORDER BY scientific_name
      LIMIT $1
      OFFSET $2;
      SQL

      result = query(sql, [limit, offset, inventory_id] + params)
    else # Search all
      conditions, params = filters_to_conditions(filters, 3)

      sql = <<~SQL
      SELECT plants.id AS pid, *
      FROM plants
      #{conditions.length > 0 ? 'WHERE' : ''} #{conditions} 
      ORDER BY scientific_name
      LIMIT $1
      OFFSET $2;
      SQL

      result = query(sql, [limit, offset] + params)
    end
  end
  # search : Hash of Filters, Integer -> List of Plants
  # Returns a list of `PAGE_LIMIT` plants starting at a given offset
  # Only includes public plants or plants created by the current user
  # rubocop:disable Metrics/MethodLength
  def search_all(filters = {}, inventory_id: nil, limit: PAGE_LIMIT, page: 1, inventory_only: false)
    # Note: Add functionality to include user-specific plants to result
    filters = filters.reject do |_, value|
      !value || value == ''
    end

    offset = compute_offset(page)
    result = perform_search_query(filters, offset, limit, inventory_id, inventory_only)

    # Transform tuples to Plants or InventoryPlants, dependent on whether a quantity exists
    result.map do |tuple|
      if (tuple["inventory_id"])
        InventoryPlant.new(tuple, tuple["quantity"].to_i)
      else
        Plant.new(tuple)
      end
    end
  end

  # Search inventory only
  def search_inventory(inventory_id, filters = {})
    search_all(filters, inventory_id: inventory_id, inventory_only: true)
  end

  # rubocop:enable Metrics/MethodLength

  # find_by_id : String -> Plant|InventoryPlant
  # Returns a singular plant with the given `id`
  def find_by_id(id, inventory_id: nil)
    result = search_all({ "plants.id" => id }, inventory_id: inventory_id, limit: 1)

    if result.empty?
      raise NoPlantFoundError.new, "No plant found with id #{id}."
    end

    result[0]
  end

  private
  # Retrieves a conditions string & associated parameters for that string
  # Just use a manual approach
  def filters_to_conditions(filters, first_placeholder)
    conditions = []
    condition_params = []
    n = first_placeholder

    filters.each do |filter, value|
      if filter == 'id' || filter == 'plants.id'
        conditions << "(#{filter} = $#{n})"
        condition_params.push(value.to_i)
        n += 1
      elsif NUMERICAL_FILTERS.include?(filter)
        min, max = value.split(', ')
        conditions << "(#{filter} BETWEEN $#{n} AND $#{n + 1})"
        condition_params.push(min, max)
        n += 2
      elsif value.is_a? Array
        sub_conditions = []
        value.each do |option|
          sub_conditions << "#{filter} ~* $#{n}"
          condition_params.push(option)
          n += 1
        end

        conditions << "(#{sub_conditions.join(' OR ')})"
      else
        conditions << "(#{filter} ~* $#{n})"
        condition_params.push(value)
        n += 1
      end
    end
    
    [conditions.join(' AND '), condition_params]
  end

  def filters_to_conditions_string(filters)
    conditions = filters.map do |key, value|
      filter_to_condition(key, value)
    end

    conditions.join(' AND ')
  end

  def compute_offset(page_number)
    (page_number - 1) * PAGE_LIMIT
  end
end
