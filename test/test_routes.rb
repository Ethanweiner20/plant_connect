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
    @plants_storage = PlantsStorage.new
    @users = Users.new
    @inventories = Inventories.new
    # Setup database
    @user_id = @users.create("test_user", "Password1234!", @inventories)
    @inventory_id = @inventories.find_by_user_id(@user_id).id

    [1, 4, 1005, 5, 1434, 2171, 2455, 5093, 5225, 5355, 5378].each do |plant_id|
      @inventories.add_plant(plant_id, 10, @inventory_id)
    end

    @user_session = { "rack.session" => { user_id: @user_id } }
  end

  def teardown
    @users.clear_tables
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

    assert_equal 302, last_response.status, @user_session
    refute session.key?(:user_id)
  end

  def test_plants
    get '/plants'

    assert_equal 200, last_response.status
    refute_includes last_response.body, '<div class="card'
  end

  def test_plants_with_empty_filters    
    get '/plants', { "page" => "1", "common_name" => "", "scientific_name" => "" }

    assert_equal 200, last_response.status
    assert_includes last_response.body, '<div class="card'
  end

  # Test plants page, some in inventory, some not
  def test_plants_with_filters
    get '/plants', { "page" => "1", "duration" => "perennial" }, @user_session

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Balsam fir"
  end

  def test_data_path
    assert_includes data_path, "plant_connect/test/data"
  end

  # Successful login: Redirects to page
  def test_successful_login
    post '/login', { "username" => "test_user", "password" => "Password1234!" }

    assert_equal 302, last_response.status
    get last_response["Location"]

    assert_equal 200, last_response.status
  end

  def test_failure_login
    post '/login', { "username" => "test_user", "password" => "password1234!" }

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Invalid username or password."
  end

  # Note: Adds user to the database
  def test_successful_signup
    post '/users', { "username" => "noah", "password" => "Noah12999!" }

    assert_equal 302, last_response.status
    get last_response["Location"]

    assert_equal 200, last_response.status

    get "/logout"

    post '/login', { "username" => "noah", "password" => "Noah12999!" }
    assert_equal 302, last_response.status
  end

  def test_invalid_password_signup
    post '/users', { "username" => "noah", "password" => "Noah" }

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Password must contain at least 8 "\
                                        "characters, a number, and uppercase letter."
  end

  def test_username_taken_signup
    post '/users', { "username" => "test_user", "password" => "GoodPassword123" }

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Username 'test_user' is already taken."
  end

  def test_authenticated_route_success
    get '/inventories/user', { "page" => "1" }, @user_session
    assert_equal 200, last_response.status
  end

  def test_authenticated_route_failure
    get '/inventories/user', { "page" => "1" }
    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_equal 200, last_response.status
    assert_includes last_response.body, "You must be logged in to do that."
  end

  def test_plant_page_usda
    get '/plants/4'
    assert_equal 200, last_response.status
    assert_includes last_response.body, "Balsam fir"
    assert_includes last_response.body, "Perennial"
    assert_includes last_response.body, "+ Add Plant"
  end

  def test_plant_page_inventory
    get '/plants/4', {}, @user_session
    assert_equal 200, last_response.status
    assert_includes last_response.body, "Balsam fir"
    assert_includes last_response.body, "Perennial"
    assert_includes last_response.body, "New Amount"
  end

  def test_inventory_no_filters
    get '/inventories/user?page=1', {}, @user_session
    assert_equal 200, last_response.status
    assert_includes last_response.body, "Balsam fir"
    assert_includes last_response.body, "New Amount"
  end

  def test_inventory_with_filters
    get '/inventories/user?page=1', { "common_name" => "Balsam" }, @user_session
    assert_equal 200, last_response.status
    assert_includes last_response.body, "Balsam fir"
    assert_includes last_response.body, "New Amount"

    get '/inventories/user?page=1', { "common_name" => "1234" }, @user_session
    assert_equal 200, last_response.status
    assert_includes last_response.body, "No plants found."
  end

  def test_add_plant
    post '/inventories/user', { "plant_id" => "30", "quantity" => "10" }, @user_session
    assert_equal 10, @plants_storage.search_inventory(@inventory_id, { "plants.id" => "30" })[0].quantity
  end

  def test_add_duplicate
    post '/inventories/user', { "plant_id" => "4" }, @user_session
    assert_equal 400, last_response.status
  end

  def test_add_plant_invalid_quantity
    post '/inventories/user/4/update', { "quantity" => "0.5" }, @user_session
    assert_equal 400, last_response.status

    post '/inventories/user/4/update', { "quantity" => "-30" }, @user_session
    assert_equal 400, last_response.status

    post '/inventories/user/4/update', { "quantity" => "abc" }, @user_session
    assert_equal 400, last_response.status
  end

  def test_update_quantity
    plant = { id: "4", quantity: 100 }
    post '/inventories/user/4/update', plant, @user_session
    assert_equal 100, @plants_storage.search_inventory(@inventory_id, { "plants.id" => "4" })[0].quantity
  end

  def test_update_quantity_invalid_plant
    post '/inventories/user/30/update', { "quantity": "100" }, @user_session
    assert_equal 400, last_response.status
    assert_includes last_response.body, "This plant is not in your inventory."
  end

  def test_delete_plant
    post '/inventories/user/4/delete', {}, @user_session
    assert_equal 204, last_response.status
    assert_equal 0, @plants_storage.search_inventory(@inventory_id, { "plants.id" => "4" }).length
  end

  def test_invalid_plant_id
    get '/plants/-3'
    assert_equal 400, last_response.status
    assert_includes last_response.body, "No plant found with id -3."

    get '/plants/1000000'
    assert_equal 400, last_response.status
  end
end
