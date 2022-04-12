ENV["RACK_ENV"] = "test"

require 'minitest/autorun'
require "minitest/reporters"

Minitest::Reporters.use!

require "rack/test"
require_relative '../app.rb'

class PlantConnectTest < MiniTest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    # Authenticated environment
    @sample_plant = { id: "4", quantity: 10 }

    @sample_user = {
      "name" => "admin",
      "password" => "Secret1!",
      "inventory" => {
        "name" => "My Inventory",
        "plants" => [@sample_plant]
      }
    }
    @admin_session = { "rack.session" => { user: @sample_user } }
  end

  def session
    last_request.env["rack.session"]
  end

  def test_index
    get '/'

    assert_equal 302, last_response.status
  end

  def test_logout
    post '/logout'

    assert_equal 302, last_response.status, @admin_session
    refute session.key?(:user)
  end

  def test_plants
    get '/plants'

    assert_equal 200, last_response.status
    refute_includes last_response.body, '<div class="card">'
  end

  def test_plants_with_empty_filters
    get '/plants', { "CommonName" => "", "ScientificName" => "" }

    assert_equal 200, last_response.status
    assert_includes last_response.body, "No filters were provided."
  end

  # Test plants page, some in inventory, some not
  def test_plants_with_filters
    get '/plants', { "Duration" => "Perennial" }, @admin_session

    assert_equal 200, last_response.status
    assert_includes last_response.body, "silver fir"
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
    get '/inventory', {}, @admin_session
    assert_equal 200, last_response.status
  end

  def test_authenticated_route_failure
    get '/inventory', {}
    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_equal 200, last_response.status
    assert_includes last_response.body, "You must be logged in to do that."
  end

  def test_plant_page_usda
    get '/plants/4'
    assert_equal 200, last_response.status
    assert_includes last_response.body, "silver fir"
    assert_includes last_response.body, "Perennial"
    assert_includes last_response.body, "+ Add Plant"
  end

  def test_plant_page_inventory
    get '/plants/4', {}, @admin_session
    assert_equal 200, last_response.status
    assert_includes last_response.body, "silver fir"
    assert_includes last_response.body, "Perennial"
    assert_includes last_response.body, "New Amount"
  end

  def test_inventory_no_filters
    get '/inventory', {}, @admin_session
    assert_equal 200, last_response.status
    assert_includes last_response.body, "silver fir"
    assert_includes last_response.body, "New Amount"
  end

  def test_inventory_with_filters
    get '/inventory', { "CommonName" => "Silver" }, @admin_session
    assert_equal 200, last_response.status
    assert_includes last_response.body, "silver fir"
    assert_includes last_response.body, "New Amount"

    get '/inventory', { "CommonName" => "1234" }, @admin_session
    assert_equal 200, last_response.status
    assert_includes last_response.body, "No plants found."
  end

  def test_add_plant
    plant = { id: "10", quantity: 5 }
    post '/inventory', plant, @admin_session
    assert_includes session["user"]["inventory"]["plants"], plant
  end

  def test_add_duplicate
    plant = { id: "4", quantity: 15 }
    post '/inventory', plant, @admin_session
    assert_equal 400, last_response.status
  end

  def test_add_plant_invalid_quantity
    plant = { id: "10", quantity: 0.5 }
    post '/inventory', plant, @admin_session
    assert_equal 400, last_response.status

    plant = { id: "10", quantity: -15 }
    post '/inventory', plant, @admin_session
    assert_equal 400, last_response.status

    plant = { id: "10", quantity: "abc" }
    post '/inventory', plant, @admin_session
    assert_equal 400, last_response.status
  end

  def test_update_quantity
    plant = { id: "4", quantity: 100 }
    post '/inventory/4/update', plant, @admin_session
    assert_includes session["user"]["inventory"]["plants"], plant
  end

  def test_update_quantity_invalid_plant
    plant = { id: "5", quantity: 100 }
    post '/inventory/5/update', plant, @admin_session
    assert_equal 400, last_response.status
    assert_includes last_response.body, "This plant is not in your inventory."
  end

  def test_delete_plant
    post '/inventory/4/delete', {}, @admin_session
    assert_equal 204, last_response.status
    assert_equal 0, session["user"]["inventory"]["plants"].size
    refute_includes session["user"]["inventory"]["plants"], @plant
  end

  def test_invalid_plant_id
    get '/plants/-3'
    assert_equal 400, last_response.status
    assert_includes last_response.body, "No plant found with id -3."

    get '/plants/1000000'
    assert_equal 400, last_response.status
  end
end
