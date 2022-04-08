require 'minitest/autorun'
require "minitest/reporters"
Minitest::Reporters.use!

require_relative '../lib/plant.rb'

class PlantTest < MiniTest::Test
  def test_image_search
    data = { "ScientificName" => "hosta sieboldiana", "CommonName" => "Hosta" }
    plant = Plant.new(data)
    assert plant.image_src
  end

  def test_image_search_no_find
    data = { "ScientificName" => "", "CommonName" => "Hostawt235" }
    plant = Plant.new(data)
    assert_nil plant.image_src
  end

  def test_image_search_common_name
    data = { "ScientificName" => "", "CommonName" => "Hosta" }
    plant = Plant.new(data)
    assert plant.image_src
  end

  def test_image_search_hosta
    data = { "ScientificName" => "", "CommonName" => "helminthostachys" }
    plant = Plant.new(data)
    assert plant.image_src
  end
end
