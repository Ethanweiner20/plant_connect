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

  def setup
    # Authenticated environment
    @sample_user = {
      "name" => "admin",
      "password" => "Secret1!",
      "inventory" => {
        "name" => "My Inventory",
        "plants" => []
      }
    }
    @admin_session = { "rack.session" => { user: @sample_user } }
  end

  def test_plants
    get '/plants'

    assert_equal 200, last_response.status
    refute_includes last_response.body, '<div class="card">'
  end

  def test_data_path
    assert_includes data_path, "plant_connect/test/data"
  end

  # Successful login: Redirects to page
  def test_successful_login
    get '/users', { "username" => "admin", "password" => "Secret1!" }

    assert_equal 302, last_response.status
    get last_response["Location"]

    assert_equal 200, last_response.status
  end

  def test_failure_login
    get '/users', { "username" => "admin", "password" => "secret1!" }

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Invalid username or password."
  end

  def test_successful_signup
    skip
    post '/users', { "username" => "noah", "password" => "Noah12999" }

    assert_equal 302, last_response.status
    get last_response["Location"]

    assert_equal 200, last_response.status

    get "/logout"

    get '/users', { "username" => "noah", "password" => "Noah12999" }
    assert_equal 302, last_response.status
  end

  def test_invalid_password_signup
    skip
    post '/users', { "username" => "noah", "password" => "Noah" }

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Password must contain at least 8 characters, a number, and uppercase letter."
  end

  def test_username_taken_signup
    skip
    post '/users', { "username" => "ethan", "password" => "GoodPassword123" }

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Username is already taken."
  end

  def test_authenticated_route_success
    get '/inventory', { "id": "10" }, @admin_session
    assert_equal 200, last_response.status
  end

  def test_authenticated_route_failure
    get '/inventory', { "id": "10" }
    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_equal 200, last_response.status
    assert_includes last_response.body, "You must be logged in to do that."
  end

  def test_plant_page_usda
    skip
  end

  def test_plant_page_inventory
    skip
  end

  def test_inventory_no_filters
    skip
  end

  def test_inventory_with_filters
    skip
  end

  def test_add_plant
    skip
  end

  def test_update_quantity
    skip
  end

  def test_add_plant_invalid_quantity
    skip
  end

  def test_delete_plant
    skip
  end

  def test_invalid_plant_id
    skip
  end
end
