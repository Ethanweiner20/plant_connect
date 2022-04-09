require 'minitest/autorun'
require "minitest/reporters"
Minitest::Reporters.use!

require_relative '../lib/usda_plants_api.rb'

class USDAPlantsTest < MiniTest::Test
  TEMPORARY_SEARCH_LIMIT = 500

  def test_common_name
    assert_equal 1, USDAPlants.search({ "CommonName" => "Arizona boxelder" }, limit: TEMPORARY_SEARCH_LIMIT)[:plants].size
    assert_equal 1, USDAPlants.search({ "CommonName" => "Arizona boxe" }, limit: TEMPORARY_SEARCH_LIMIT)[:plants].size
    assert_equal 1, USDAPlants.search({ "CommonName" => "arizona Boxelder" }, limit: TEMPORARY_SEARCH_LIMIT)[:plants].size
    assert_equal 2, USDAPlants.search({ "CommonName" => "Boxelder" }, limit: TEMPORARY_SEARCH_LIMIT)[:plants].size
  end

  def test_no_filters
    assert_equal 0, USDAPlants.search({}, limit: TEMPORARY_SEARCH_LIMIT)[:plants].size
  end

  def test_empty_filters
    filters = {
      "CommonName" => "Arizona boxelder",
      "ScientificName" => ""
    }
    assert_equal 1, USDAPlants.search(filters, limit: TEMPORARY_SEARCH_LIMIT)[:plants].size

    filters = {
      "CommonName" => "Arizona boxelder",
      "ScientificName" => nil
    }
    assert_equal 1, USDAPlants.search(filters, limit: TEMPORARY_SEARCH_LIMIT)[:plants].size
  end

  def test_multiple_filters
    filters = {
      "CommonName" => "Arizona boxelder",
      "ScientificName" => "Acer negundo var. arizonicum"
    }

    assert_equal 1, USDAPlants.search(filters, limit: TEMPORARY_SEARCH_LIMIT)[:plants].size

    filters = {
      "CommonName" => " boxelder",
      "ScientificName" => "acer"
    }

    assert_equal 2, USDAPlants.search(filters, limit: TEMPORARY_SEARCH_LIMIT)[:plants].size
  end

  def test_invalid_filters
    filters = {
      "Com Name" => " boxelder",
      "ScientificName" => "acer"
    }

    assert_raises(StandardError) { USDAPlants.search(filters, limit: TEMPORARY_SEARCH_LIMIT)[:plants].size }
  end

  def test_search_limit
    filters = { "Genus" => "Acer" }
    assert_equal USDAPlants::SEARCH_LIMIT, USDAPlants.search(filters, limit: TEMPORARY_SEARCH_LIMIT)[:plants].size
  end

  def test_multi_value_filter
    filters = { "Genus" => "Albizia", "GrowthHabit" => ["Tree", "Shrub"] }
    assert_equal 4, USDAPlants.search(filters, limit: TEMPORARY_SEARCH_LIMIT)[:plants].size

    filters = { "Genus" => "Albizia", "GrowthHabit" => ["Tree"] }
    assert_equal 4, USDAPlants.search(filters, limit: TEMPORARY_SEARCH_LIMIT)[:plants].size

    filters = { "Genus" => "Albizia", "GrowthHabit" => ["Shrub"] }
    assert_equal 1, USDAPlants.search(filters, limit: TEMPORARY_SEARCH_LIMIT)[:plants].size
  end

  def test_mulit_value_filter_with_and
    filters = { "Genus" => "Agrostis", "ActiveGrowthPeriod" => ["Spring", "Summer"] }
    assert_equal 2, USDAPlants.search(filters, limit: TEMPORARY_SEARCH_LIMIT)[:plants].size

    filters = { "Genus" => "Agrostis", "ActiveGrowthPeriod" => ["Summer"] }
    assert_equal 2, USDAPlants.search(filters, limit: TEMPORARY_SEARCH_LIMIT)[:plants].size
  end

  def test_range
    # Question: What is the minimum precipitation the plant needs?
    filters = { "Genus" => "Abies", "Precipitation_Minimum" => "20, 42" }
    assert_equal 3, USDAPlants.search(filters, limit: TEMPORARY_SEARCH_LIMIT)[:plants].size

    # Question: What is the maximum precipitation the plant can withstand?
    filters = { "Genus" => "Abies", "Precipitation_Maximum" => "75, 85" }
    assert_equal 2, USDAPlants.search(filters, limit: TEMPORARY_SEARCH_LIMIT)[:plants].size

    # Return all plants whose min temperature is between the two values
    filters = { "Genus" => "Abies", "TemperatureMinimum" => "-40, -20" }
    assert_equal 2, USDAPlants.search(filters, limit: TEMPORARY_SEARCH_LIMIT)[:plants].size
  end

  def test_offset; end
end
