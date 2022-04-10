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
end
