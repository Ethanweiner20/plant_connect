require 'csv'
require 'pry'

class USDAPlants
  SEARCH_LIMIT = 10

  CSV_PATH = 'data/plants.csv'

  # search : Hash of Filters, Integer -> List of Plants
  # Return a list of 10 plants, starting at `start`
  def self.search(filters, _start=0)
    filters = filters.reject { |_, value| !value || value.empty? }
    index = 0
    plants = []

    CSV.foreach(CSV_PATH, "r:ISO-8859-1", headers: true, liberal_parsing: true) do |row|
      index += 1
      if match?(row, filters)
        plants << row.to_h
        break if plants.size == SEARCH_LIMIT
      end
    end

    { plants: plants, last_index: index }
  end

  def self.match?(row, filters)
    filters.all? do |key, value|
      raise "Invalid filter" unless row[key]
      values_match?(row[key], value)
    end
  end

  def self.values_match?(actual_value, search_value)
    actual_value.strip.downcase.include?(search_value.strip.downcase)
  end
end
