require 'minitest/autorun'
require "minitest/reporters"
Minitest::Reporters.use!

require_relative '../lib/usda_plants_api.rb'

class USDAPlantsTest < MiniTest::Test
  def test_common_name
    assert_equal 1, USDAPlants.search({ "CommonName" => "Arizona boxelder" }, limit: 500)[:plants].size
    assert_equal 1, USDAPlants.search({ "CommonName" => "Arizona boxe" }, limit: 500)[:plants].size
    assert_equal 1, USDAPlants.search({ "CommonName" => "arizona Boxelder" }, limit: 500)[:plants].size
    assert_equal 2, USDAPlants.search({ "CommonName" => "Boxelder" }, limit: 500)[:plants].size
  end

  def test_no_filters
    assert_equal 0, USDAPlants.search({}, limit: 500)[:plants].size
  end

  def test_empty_filters
    filters = {
      "CommonName" => "Arizona boxelder",
      "ScientificName" => ""
    }
    assert_equal 1, USDAPlants.search(filters, limit: 500)[:plants].size

    filters = {
      "CommonName" => "Arizona boxelder",
      "ScientificName" => nil
    }
    assert_equal 1, USDAPlants.search(filters, limit: 500)[:plants].size
  end

  def test_multiple_filters
    filters = {
      "CommonName" => "Arizona boxelder",
      "ScientificName" => "Acer negundo var. arizonicum"
    }

    assert_equal 1, USDAPlants.search(filters, limit: 500)[:plants].size

    filters = {
      "CommonName" => " boxelder",
      "ScientificName" => "acer"
    }

    assert_equal 2, USDAPlants.search(filters, limit: 500)[:plants].size
  end

  def test_invalid_filters
    filters = {
      "Com Name" => " boxelder",
      "ScientificName" => "acer"
    }

    assert_raises(StandardError) { USDAPlants.search(filters, limit: 500)[:plants].size }
  end

  def test_search_limit
    filters = { "Genus" => "Acer" }
    assert_equal USDAPlants::SEARCH_LIMIT, USDAPlants.search(filters, limit: 500)[:plants].size
  end

  def test_multi_value_filter
    filters = { "Genus" => "Albizia", "GrowthHabit" => ["Tree", "Shrub"] }
    assert_equal 4, USDAPlants.search(filters, limit: 500)[:plants].size

    filters = { "Genus" => "Albizia", "GrowthHabit" => ["Tree"] }
    assert_equal 4, USDAPlants.search(filters, limit: 500)[:plants].size

    filters = { "Genus" => "Albizia", "GrowthHabit" => ["Shrub"] }
    assert_equal 1, USDAPlants.search(filters, limit: 500)[:plants].size
  end

  def test_offset; end
end
