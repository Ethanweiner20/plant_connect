require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader'
also_reload('lib/*.rb')

require 'tilt/erubis'
require_relative 'lib/plant.rb'
require_relative 'lib/usda_plants_api.rb'
require 'yaml'
require 'pry'

configure do
  enable :sessions
  set :session_secret, "secret"
end

# HELPERS

ROOT = File.expand_path(__dir__)

def data_path
  ENV["RACK_ENV"] == "test" ? "#{ROOT}/test/data" : "#{ROOT}/data"
end

def file_path(file_name)
  data_path + '/' + file_name
end

def search_inventory(id)
  return nil unless @user
  @inventory["plants"].find do |plant|
    plant[:id] == id
  end
end

def valid_quantity?(quantity)
  quantity.to_i.to_s == quantity && quantity.to_i >= 0
end

def unique?(id)
  !search_inventory(id)
end

def protected!
  return if @user
  session[:error] = "You must be logged in to do that."
  redirect '/login' unless @user
end

# FILTERS

before do
  @user = session[:user]
  @inventory = @user ? @user["inventory"] : nil
end

before '/inventory*' do
  protected!
end

before '/community*' do
  protected!
end

get '/' do
  redirect '/plants'
end

# AUTHENTICATION

def logout
  session.delete(:user)
end

post '/logout' do
  logout
  redirect '/login'
end

get '/login' do
  logout
  erb :login
end

def valid_login_credentials?(username, password, users)
  users.key?(username) && users[username]["password"] == password
end

get '/users' do
  username = params[:username]
  password = params[:password]

  users = YAML.load_file(file_path('users.yml'))

  if valid_login_credentials?(username, password, users)
    user = users[username]
    session[:user] = user
    redirect '/inventory'
  else
    session[:error] = "Invalid username or password."
    @username = username
    erb :login
  end
end

# SIGNUP: Temporarily disabled
get '/signup' do
  # Temporary
  redirect '/login'
  logout
  erb :signup
end

def strong_password?(password)
  password =~ /.{8,}/ && password =~ /[A-Z]/ && password =~ /[0-9]/
end

def valid_signup_credentials?(username, password, users)
  !users.key?(username) && strong_password?(password)
end

post '/users' do
  redirect '/inventory'
end

# SEARCH ALL PLANTS

def mixin_inventory(plants)
  plants.map do |plant|
    inventory_plant = search_inventory(plant.id)
    if inventory_plant
      UserPlant.new(inventory_plant[:id], quantity: inventory_plant[:quantity],
                                          data: plant.data)
    else
      plant
    end
  end
end

def render_search_results(filters)
  search_limit = settings.development? ? 500 : 10000

  result = USDAPlants.search(filters, max_index: search_limit)

  @plants = mixin_inventory(result[:plants])

  @last_index = result[:last_index]

  erb(:plants, layout: nil)
end

# Render form or plants list
get '/plants' do
  @title = "Search"
  @subtitle = "Search for plants using any number of filters."

  if params.empty?
    erb :search
  elsif params.values.all?(&:empty?)
    session[:error] = "No filters were provided."
    erb :search
  else
    filters = params.clone
    filters.delete(:page)
    erb(:search) + render_search_results(filters)
  end
end

# VIEW SINGULAR PLANTS

get '/plants/:id' do
  id = params["id"]

  begin
    plant = search_inventory(id)

    @plant = if plant
               UserPlant.new(plant[:id], quantity: plant[:quantity])
             else
               USDAPlants.find_by_id(id)
             end
  rescue NoPlantFoundError => e
    session[:error] = e.message
    status 400
  end

  erb :plant
end

# INVENTORY

# Render the inventory using some filters
def render_inventory(filters: nil)
  @plants = @inventory["plants"].map do |plant|
    UserPlant.new(plant[:id], quantity: plant[:quantity])
  end

  if filters
    @plants = @plants.select do |plant|
      USDAPlants.match?(plant.data, filters)
    end
  end

  erb(:plants, layout: nil)
end

# Manage inventory
get '/inventory' do
  redirect '/login' unless @user

  @title = "Inventory"
  @subtitle = "Browse plants saved in your inventory."

  if params.empty? || params.values.all?(&:empty?)
    erb(:search) + render_inventory
  else
    filters = params.clone
    filters.delete(:page)
    erb(:search) + render_inventory(filters: filters)
  end
end

def verify_quantity
  quantity = params["quantity"]

  if valid_quantity?(quantity)
    yield(quantity.to_i)
    status 204
  else
    status 400
    "Quantity must be a non-negative integer."
  end
end

def verify_uniqueness
  id = params["id"]

  if unique?(id)
    yield
  else
    status 400
    "This plant is already in your inventory."
  end
end

# AJAX: Add a plant to a user's inventory
post '/inventory' do
  verify_uniqueness do
    verify_quantity do |quantity|
      plant = { id: params["id"], quantity: quantity }
      @inventory["plants"].unshift(plant)
    end
  end
end

# AJAX: Update quantity of plant in inventory
post '/inventory/:id/update' do
  verify_quantity do |quantity|
    plant_to_update = search_inventory(params["id"])
    plant_to_update[:quantity] = quantity
  end
end

# AJAX: Delete plant from inventory
post '/inventory/:id/delete' do
  @inventory["plants"].delete_if do |plant|
    plant[:id] == params["id"]
  end

  status 204
end

# CUSTOM PLANTS

# Add plant to a user's custom plants
get '/users/plants/new' do
end

post '/users/plants' do
end

# Edit a custom plant
get '/users/plants/:id/edit' do
end

post '/users/plants/:id' do
end

# COMMUNITY

get '/community' do
  redirect '/login' unless @user
  erb :community
end

# SETTINGS

get '/settings' do
  erb :settings
end
