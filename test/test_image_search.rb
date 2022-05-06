ENV["RACK_ENV"] = "test"

require 'minitest/autorun'
require "minitest/reporters"

Minitest::Reporters.use!

require "rack/test"

require_relative '../lib/plant'

class ImageSearchTest < MiniTest::Test
  def test_image_search
    data = { "scientific_name" => "hosta sieboldiana", "common_name" => "Hosta" }
    plant = Plant.new(data)
    assert plant.image_src
  end

  def test_image_search_no_find
    data = { "scientific_name" => "", "common_name" => "Hostawt235" }
    plant = Plant.new(data)
    assert_nil plant.image_src
  end

  def test_image_search_common_name
    data = { "scientific_name" => "", "common_name" => "Hosta" }
    plant = Plant.new(data)
    assert plant.image_src
  end
end
