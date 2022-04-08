require 'minitest/autorun'
require "minitest/reporters"
Minitest::Reporters.use!

require_relative '../lib/plant.rb'

class PlantTest < MiniTest::Test
  def test_image_search
    data = { "Scientific Name" => "hosta sieboldiana", "Common Name" => "Hosta" }
    plant = Plant.new(data)
    assert plant.image_src
  end

  def test_image_search_no_find
    data = { "Scientific Name" => "", "Common Name" => "Hostawt235" }
    plant = Plant.new(data)
    assert_nil plant.image_src
  end

  def test_image_search_common_name
    data = { "Scientific Name" => "", "Common Name" => "Hosta" }
    plant = Plant.new(data)
    assert plant.image_src
  end

  def test_image_search_hosta
    data = { "Scientific Name" => "", "Common Name" => "helminthostachys" }
    plant = Plant.new(data)
    assert plant.image_src
  end
end
