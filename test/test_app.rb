ENV["RACK_ENV"] = "test"

require 'minitest/autorun'
require "rack/test"
require 'minitest/reporters'
Minitest::Reporters.use!

require_relative '../app.rb'

class PlantConnectTest < MiniTest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_plants
    get '/search'

    assert_equal 200, last_response.status
    refute_includes last_response.body, '<div class="card">'
  end
end
