ENV["RACK_ENV"] = "test"

require 'minitest/autorun'
require "minitest/reporters"

Minitest::Reporters.use!

require "rack/test"
require_relative '../app'

class BloomShareTest < MiniTest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    @sample_user = {
      "user_id" => "abcdef",
      "username" => "admin",
      "num_plants_added" => "0"
    }
    @admin_session = { "rack.session" => { user_id: "abcdef" } }
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
    refute session.key?(:user_id)
  end

  def test_plants
    get '/plants'

    assert_equal 200, last_response.status
    refute_includes last_response.body, '<div class="card">'
  end

  def test_plants_with_empty_filters
    get '/plants', { "page" => "1", "common_name" => "", "scientific_name" => "" }

    assert_equal 200, last_response.status
    assert_includes last_response.body, "No filters were provided."
  end

  # Test plants page, some in inventory, some not
  def test_plants_with_filters
    get '/plants', { "page" => "1", "duration" => "perennial" }, @admin_session

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Balsam fir"
  end

  def test_data_path
    assert_includes data_path, "plant_connect/test/data"
  end

  # Successful login: Redirects to page
  def test_successful_login
    post '/login', { "username" => "admin", "password" => "Secret1!" }

    assert_equal 302, last_response.status
    get last_response["Location"]

    assert_equal 200, last_response.status
  end

  def test_failure_login
    post '/login', { "username" => "admin", "password" => "secret1!" }

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Invalid username or password."
  end

  # Note: Adds user to the database
  def test_successful_signup
    skip

    post '/users', { "username" => "noah", "password" => "Noah12999" }

    assert_equal 302, last_response.status
    get last_response["Location"]

    assert_equal 200, last_response.status

    get "/logout"

    post '/login', { "username" => "noah", "password" => "Noah12999" }
    assert_equal 302, last_response.status
  end

  def test_invalid_password_signup
    post '/users', { "username" => "noah", "password" => "Noah" }

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Password must contain at least 8 "\
                                        "characters, a number, and uppercase letter."
  end

  def test_username_taken_signup
    post '/users', { "username" => "admin", "password" => "GoodPassword123" }

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Username 'admin' is already taken."
  end

  def test_authenticated_route_success
    get '/inventory?page=1', {}, @admin_session
    assert_equal 200, last_response.status
  end

  def test_authenticated_route_failure
    get '/inventory?page=1', {}
    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_equal 200, last_response.status
    assert_includes last_response.body, "You must be logged in to do that."
  end

  def test_plant_page_usda
    skip
    get '/plants/4'
    assert_equal 200, last_response.status
    assert_includes last_response.body, "silver fir"
    assert_includes last_response.body, "Perennial"
    assert_includes last_response.body, "+ Add Plant"
  end

  def test_plant_page_inventory
    skip
    get '/plants/4', {}, @admin_session
    assert_equal 200, last_response.status
    assert_includes last_response.body, "silver fir"
    assert_includes last_response.body, "Perennial"
    assert_includes last_response.body, "New Amount"
  end

  def test_inventory_no_filters
    skip
    get '/inventory?page=1', {}, @admin_session
    assert_equal 200, last_response.status
    assert_includes last_response.body, "silver fir"
    assert_includes last_response.body, "New Amount"
  end

  def test_inventory_with_filters
    skip
    get '/inventory?page=1', { "CommonName" => "Silver" }, @admin_session
    assert_equal 200, last_response.status
    assert_includes last_response.body, "silver fir"
    assert_includes last_response.body, "New Amount"

    get '/inventory?page=1', { "CommonName" => "1234" }, @admin_session
    assert_equal 200, last_response.status
    assert_includes last_response.body, "No plants found."
  end

  def test_add_plant
    skip
    plant = { id: "10", quantity: 5 }
    post '/inventory?page=1', plant, @admin_session
    assert_includes session["user"]["inventory"]["plants"], plant
  end

  def test_add_duplicate
    skip
    plant = { id: "4", quantity: 15 }
    post '/inventory?page=1', plant, @admin_session
    assert_equal 400, last_response.status
  end

  def test_add_plant_invalid_quantity
    skip
    plant = { id: "10", quantity: 0.5 }
    post '/inventory?page=1', plant, @admin_session
    assert_equal 400, last_response.status

    plant = { id: "10", quantity: -15 }
    post '/inventory?page=1', plant, @admin_session
    assert_equal 400, last_response.status

    plant = { id: "10", quantity: "abc" }
    post '/inventory?page=1', plant, @admin_session
    assert_equal 400, last_response.status
  end

  def test_update_quantity
    skip
    plant = { id: "4", quantity: 100 }
    post '/inventory?page=1/4/update', plant, @admin_session
    assert_includes session["user"]["inventory"]["plants"], plant
  end

  def test_update_quantity_invalid_plant
    skip
    plant = { id: "5", quantity: 100 }
    post '/inventory?page=1/5/update', plant, @admin_session
    assert_equal 400, last_response.status
    assert_includes last_response.body, "This plant is not in your inventory."
  end

  def test_delete_plant
    skip
    post '/inventory?page=1/4/delete', {}, @admin_session
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
