=begin

Wishlist:

- Plants#initialize(logger, user_id)
  - Connect to plant database
  - Setup the logger
  - Store the current `user_id` for use in searches
- Plants#search: Returns all public plants + all plants created by given user

Note: Uses the `Plant` class for plant creation

=end

require 'csv'
require_relative './plant'

class NoPlantFoundError < StandardError
  def initialize(msg="No plant found.")
    super(msg)
  end
end

class PlantsStorage
  SEARCH_LIMIT = 10

  READ_FORM = "r:ISO-8859-1"

  NUMERICAL_FILTERS = %w(Precipitation_Minimum
                         Precipitation_Maximum
                         TemperatureMinimum)

  def initialize(logger: nil, user_id: nil)
    @csv_path = 'data/plants.csv'
    @logger = logger
    @user_id = user_id
  end

  # find_by_id : String -> Plant
  # Returns a singular plant with the given `id`
  def find_by_id(id)
    result = search({ "SpeciesID" => id }, limit: 1)

    if result[:plants].empty?
      raise NoPlantFoundError.new, "No plant found with id #{id}."
    end

    result[:plants][0]
  end

  # search : Hash of Filters, Integer -> List of Plants
  # Returns a list of `SEARCH_LIMIT` plants starting at a given offset
  # Only includes public plants or plants created by the current user
  # rubocop:disable Metrics/MethodLength
  def search(filters, max_index: 500, limit: SEARCH_LIMIT)
    # Note: Add functionality to include user-specific plants to result
    filters = filters.reject { |_, value| !value || value.empty? }
    return { plants: [], last_index: 0 } if filters.empty?

    index = 0
    plants = []

    CSV.foreach(@csv_path, READ_FORM, headers: true, liberal_parsing: true) do |row|
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
  # rubocop:enable Metrics/MethodLength

  def match?(row, filters)
    filters.all? do |key, value|
      raise "Invalid filter: #{key}" unless row[key]
      values_match?(key, row[key], value)
    end
  end

  def values_match?(key, actual_value, search_value)
    if NUMERICAL_FILTERS.include?(key)
      in_range?(search_value, actual_value)
    elsif search_value.is_a? Array
      arrays_overlap?(actual_value.split(/(, )|( and )/), search_value)
    else
      strings_match?(actual_value, search_value)
    end
  end

  def in_range?(range_string, value)
    min, max = range_string.split(', ').map(&:to_i)
    (min..max).cover?(value.to_i)
  end

  def strings_match?(actual_string, search_string)
    actual_string.strip.downcase.include?(search_string.strip.downcase)
  end

  def arrays_overlap?(actual_array, search_array)
    search_array.any? do |search_ele|
      actual_array.any? do |actual_ele|
        actual_ele.downcase == search_ele.downcase
      end
    end
  end
end
