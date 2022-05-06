require 'simplecov'

ENV["RACK_ENV"] = "test"

require 'minitest/autorun'
require "minitest/reporters"

Minitest::Reporters.use!

require "rack/test"

require_relative '../lib/plants_storage'

require 'pry'

class PlantsTest < MiniTest::Test
  def setup
    @plants_storage = PlantsStorage.new
  end

  # rubocop:disable Metrics/LineLength
  def test_common_name
    assert_equal 1, @plants_storage.search({ "common_name" => "amethyst eryngo" }).size
    assert_equal 1, @plants_storage.search({ "common_name" => "st Eryngo" }).size
  end

  def test_no_filters
    assert_equal 0, @plants_storage.search({}).size
  end

  def test_empty_filters
    filters = {
      "common_name" => "amethyst eryngo",
      "scientific_name" => ""
    }

    assert_equal 1, @plants_storage.search(filters).size
  end

  def test_multiple_filters
    filters = {
      "common_name" => "amethyst eryngo",
      "scientific_name" => "Amethystinum"
    }

    assert_equal 1, @plants_storage.search(filters).size
  end

  def test_invalid_filters
    filters = {
      "CommonName" => " boxelder"
    }

    assert_raises(StandardError) { @plants_storage.search(filters) }
  end

  def test_search_limit
    filters = { "genus" => "Acer" }
    assert_equal PlantsStorage::PAGE_LIMIT, @plants_storage.search(filters).size
  end

  def test_multi_value_filter
    filters = { "common_name" => "am", "flower_color" => %w(pink orange) }
    assert_equal 1, @plants_storage.search(filters).size
  end

  def test_range
    filters = { "precipitation_minimum" => "50, 60" }
    assert_equal 5, @plants_storage.search(filters).size
  end

  def test_search_by_id
    filters = { "id" => "10" }
    assert_equal "alder", @plants_storage.search(filters)[0]["common_name"]
  end

  def test_pagination
    filters = { "genus" => "Acer" }
    assert_equal PlantsStorage::PAGE_LIMIT, @plants_storage.search(filters, page: 2).size

    filters = { "genus" => "Acer" }
    assert_equal 0, @plants_storage.search(filters, page: 5).size
  end
  # rubocop:enable Metrics/LineLength
end
