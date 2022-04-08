require 'minitest/autorun'
require "minitest/reporters"
Minitest::Reporters.use!

require_relative '../lib/usda_plants_api.rb'

class USDAPlantsTest < MiniTest::Test
  def test_common_name
    skip
    assert_equal 1, USDAPlants.search({ "Common Name" => "Arizona boxelder" })[:plants].size
    assert_equal 1, USDAPlants.search({ "Common Name" => "Arizona boxe" })[:plants].size
    assert_equal 1, USDAPlants.search({ "Common Name" => "arizona Boxelder" })[:plants].size
    assert_equal 7, USDAPlants.search({ "Common Name" => "Boxelder" })[:plants].size
  end

  def test_no_filters
    assert_equal 0, USDAPlants.search({})[:plants].size
  end

  def test_empty_filters
    skip
    filters = {
      "Common Name" => "Arizona boxelder",
      "Scientific Name" => ""
    }
    assert_equal 1, USDAPlants.search(filters)[:plants].size

    filters = {
      "Common Name" => "Arizona boxelder",
      "Scientific Name" => nil
    }
    assert_equal 1, USDAPlants.search(filters)[:plants].size
  end

  def test_multiple_filters
    skip
    filters = {
      "Common Name" => "Arizona boxelder",
      "Scientific Name" => "Acer negundo L. var. arizonicum Sarg."
    }

    assert_equal 1, USDAPlants.search(filters)[:plants].size

    filters = {
      "Common Name" => " boxelder",
      "Scientific Name" => "acer"
    }

    assert_equal 7, USDAPlants.search(filters)[:plants].size
  end

  def test_invalid_filters
    filters = {
      "Com Name" => " boxelder",
      "Scientific Name" => "acer"
    }

    assert_raises(StandardError) { USDAPlants.search(filters)[:plants].size }
  end

  def test_search_limit
    filters = { "Genus" => "Acer" }
    assert_equal USDAPlants::SEARCH_LIMIT, USDAPlants.search(filters)[:plants].size
  end

  def test_offset; end
end
