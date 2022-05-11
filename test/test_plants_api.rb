require 'simplecov'

ENV["RACK_ENV"] = "test"

require 'minitest/autorun'
require "minitest/reporters"

Minitest::Reporters.use!

require "rack/test"

require_relative '../lib/plants_storage'
require_relative '../lib/users'

require 'pry-byebug'

class PlantsTest < MiniTest::Test
  def setup
    @plants_storage = PlantsStorage.new
    @users = Users.new
    @inventories = Inventories.new
    # Setup database
    @user_id = @users.create("test_user", "Password1234!", @inventories)
    @inventory_id = @inventories.find_by_user_id(@user_id).id

    [1, 4, 1005, 5, 1434, 2171, 2455, 5093, 5225, 5355, 5378].each do |plant_id|
      @inventories.add_plant(plant_id, 10, @inventory_id)
    end
  end

  def teardown
    @users.clear_tables
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
    assert_equal "Balsam fir", @plants_storage.find_by_id(4)["common_name"]
    assert_equal true, @plants_storage.find_by_id(4, inventory_id: @inventory_id).is_a?(InventoryPlant)
    assert_equal false, @plants_storage.find_by_id(30, inventory_id: @inventory_id).is_a?(InventoryPlant)
  end

  def test_states
    assert_equal("AK, AZ, CO, CT, GA, IA, ID, IN, MA, MD, ME, MI, MN, MT, NC, "+ 
                 "NH, NM, NV, NY, OH, OR, PA, RI, TN, UT, VA, VT, WA, WI, WV, "+
                 "WY", @plants_storage.find_by_id(1).states)
  end

  def test_colors
    assert_equal(['Yellow', 'Green', 'Brown'], @plants_storage.find_by_id(4).colors)
  end

  def test_search_invalid_plant_id
    assert_raises(NoPlantFoundError) { @plants_storage.find_by_id(1000000) }
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
    @plants_storage.search_all(inventory_id: @inventory_id).size
    # With filters

    filters = { "scientific_name" => "abies" }

    result = @plants_storage.search_all(filters, inventory_id: @inventory_id, inventory_only: true)
    assert_equal 5, result.size

    filters = { "scientific_name" => "abies" }

    result = @plants_storage.search_inventory(@inventory_id, filters)
    assert_equal 5, result.size
  end

  def test_search_with_inventory
    filters = { "foliage_color" => ["Green"] }

    results = @plants_storage.search_all(filters, inventory_id: @inventory_id)
    assert_equal PlantsStorage::PAGE_LIMIT, results.size
    assert_equal 3, results.select { |plant| plant.is_a? InventoryPlant }.size
  end
  # rubocop:enable Metrics/LineLength
end
