require 'simplecov'

ENV["RACK_ENV"] = "test"

require 'minitest/autorun'
require "minitest/reporters"

Minitest::Reporters.use!

require "rack/test"

require_relative '../lib/plants_storage'

require 'pry-byebug'

class PlantsTest < MiniTest::Test
  def setup
    @plants_storage = PlantsStorage.new
  end

  # rubocop:disable Metrics/LineLength
  def test_common_name
    result = @plants_storage.search_all({ "common_name" => "amethyst eryngo" })
    assert_equal 1, result.size
    assert_equal 1, @plants_storage.search_all({ "common_name" => "st Eryngo" }).size
  end

  def test_no_filters
    assert_equal PlantsStorage::PAGE_LIMIT, @plants_storage.search_all({}).size
  end

  def test_empty_filters
    filters = {
      "common_name" => "amethyst eryngo",
      "scientific_name" => ""
    }

    assert_equal 1, @plants_storage.search_all(filters).size
  end

  def test_multiple_filters
    filters = {
      "common_name" => "amethyst eryngo",
      "scientific_name" => "Amethystinum"
    }

    assert_equal 1, @plants_storage.search_all(filters).size
  end

  def test_invalid_filters
    filters = {
      "CommonName" => " boxelder"
    }

    assert_raises(StandardError) { @plants_storage.search_all(filters) }
  end

  def test_search_limit
    filters = { "genus" => "Acer" }
    assert_equal PlantsStorage::PAGE_LIMIT, @plants_storage.search_all(filters).size
  end

  def test_multi_value_filter
    filters = { "common_name" => "am", "flower_color" => %w(pink orange) }
    assert_equal 1, @plants_storage.search_all(filters).size
  end

  def test_range
    filters = { "precipitation_minimum" => "50, 60" }
    assert_equal 5, @plants_storage.search_all(filters).size
  end

  def test_search_by_id
    assert_equal "white fir", @plants_storage.find_by_id(3)["common_name"]
    assert_equal true, @plants_storage.find_by_id(2, inventory_id: 1).is_a?(InventoryPlant)
    assert_equal false, @plants_storage.find_by_id(100, inventory_id: 1).is_a?(InventoryPlant)
  end

  def test_pagination
    filters = { "genus" => "Acer" }
    assert_equal PlantsStorage::PAGE_LIMIT, @plants_storage.search_all(filters, page: 2).size

    filters = { "genus" => "Acer" }
    assert_equal 0, @plants_storage.search_all(filters, page: 5).size
  end

  def test_search_all_inventory
    # Without filters
    assert_equal PlantsStorage::PAGE_LIMIT,
    @plants_storage.search_all(inventory_id: 1).size
    # With filters

    filters = { "scientific_name" => "abies" }

    result = @plants_storage.search_all(filters, inventory_id: 1, inventory_only: true)
    assert_equal 3, result.size

    # With filters

    filters = { "scientific_name" => "abies" }

    result = @plants_storage.search_inventory(1, filters)
    assert_equal 3, result.size
  end

  def test_search_with_inventory
    filters = { "foliage_color" => ["Green"] }

    results = @plants_storage.search_all(filters, inventory_id: 1)
    assert_equal PlantsStorage::PAGE_LIMIT, results.size
    assert_equal 4, results.select { |plant| plant.is_a? InventoryPlant }.size
  end
  # rubocop:enable Metrics/LineLength
end
