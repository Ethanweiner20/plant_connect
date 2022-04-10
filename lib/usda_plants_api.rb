require 'csv'
require 'pry'
require_relative './plant.rb'

class USDAPlants
  SEARCH_LIMIT = 10

  CSV_PATH = 'data/plants.csv'

  NUMERICAL_FILTERS = ["Precipitation_Minimum", "Precipitation_Maximum", "TemperatureMinimum"]

  # find : String -> Plant
  # Returns a singular plant with the given `scientific_name`
  def self.find_by_name(scientific_name)
    result = search({ "ScientificName" => scientific_name }, limit: 1)
    if result[:plants].length > 0
      result[:plants][0]
    else
      raise "No plant found for #{scientific_name}"
    end
  end

  # find_by_id : String -> Plant
  # Returns a singular plant with the given `id`
  def self.find_by_id(id)
    result = search({ "SpeciesID" => id }, limit: 1)

    if result[:plants].length > 0
      result[:plants][0]
    else
      raise "No plant found with id #{id}."
    end
  end

  # search : Hash of Filters, Integer -> List of Plants
  # Return a list of 10 plants, starting at `start`
  def self.search(filters, max_index: 500, limit: SEARCH_LIMIT)
    filters = filters.reject { |_, value| !value || value.empty? }
    return { plants: [], last_index: 0 } if filters.empty?

    index = 0
    plants = []

    CSV.foreach(CSV_PATH, "r:ISO-8859-1", headers: true, liberal_parsing: true) do |row|
      index += 1
      if match?(row, filters)
        plants << Plant.new(row.to_h)
        break if plants.size == limit
      end

      # TEMPORARY
      break if index >= max_index
    end

    { plants: plants, last_index: index }
  end

  def self.match?(row, filters)
    filters.all? do |key, value|
      raise "Invalid filter: #{key}" unless row[key]
      values_match?(key, row[key], value)
    end
  end

  def self.values_match?(key, actual_value, search_value)
    if NUMERICAL_FILTERS.include?(key)
      in_range?(search_value, actual_value)
    elsif search_value.is_a? Array
      arrays_overlap?(actual_value.split(/(, )|( and )/), search_value)
    else
      strings_match?(actual_value, search_value)
    end
  end

  def self.in_range?(range_string, value)
    min, max = range_string.split(', ').map(&:to_i)
    (min..max).cover?(value.to_i)
  end

  def self.strings_match?(actual_string, search_string)
    actual_string.strip.downcase.include?(search_string.strip.downcase)
  end

  def self.arrays_overlap?(actual_array, search_array)
    search_array.any? do |search_ele|
      actual_array.any? do |actual_ele|
        actual_ele.downcase == search_ele.downcase
      end
    end
  end
end
