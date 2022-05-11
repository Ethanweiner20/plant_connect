require 'bundler/setup'
require 'sinatra'
require 'tilt/erubis'
require_relative 'lib/helpers'
require_relative 'lib/plants'
require_relative 'lib/users'
require_relative 'lib/inventories'

# CONFIGURATION

configure do
  enable :sessions
  set :session_secret, "secret"
  set :erb, escape_html: true
end

configure(:development) do
  require 'sinatra/reloader'
  also_reload('lib/*.rb')
end

# CONSTANTS

ATTRIBUTES = {
  taxonomy: %w(class order family genus species),
  timing: %w(duration bloom_period active_growth_period growth_rate lifespan),
  growth_requirements: %w(drought_tolerance shade_tolerance fire_resistance
                          fertility_requirement),
  reproduction: %w(resprout_ability seed_spread_rate),
  physical_characteristics: %w(mature_height growth_habit growth_form
                               foliage_texture),
  colors: %w(foliage_color flower_color fruit_color)
}

# FILTERS

before do
  @users = Users.new(logger: logger)
  @user = @users.find_by_id(session[:user_id]) if session.key?(:user_id)
  @plants = Plants.new(logger: logger)
  @inventories = Inventories.new(logger: logger)
  @user_inventory = @inventories.find_by_user_id(@user["id"]) if @user
  @user_inventory_id = @user_inventory.id if @user_inventory
end

PROTECTED_ROUTES = ['/inventories*', '/community', '/settings']

PROTECTED_ROUTES.each do |route|
  before route do
    protected!
  end
end

after do
  [@users, @plants, @inventories].each(&:close_connection)
end

# INDEX

get '/' do
  redirect '/plants'
end

# AUTHENTICATION

# Logout
post '/logout' do
  logout
  redirect '/login'
end

# Render the login page
get '/login' do
  logout
  erb :login
end

# Login
post '/login' do
  username = params[:username]
  password = params[:password]

  begin
    session[:user_id] = @users.authenticate(username, password)
    redirect session[:next_path] || '/inventories/user'
  rescue InvalidLoginCredentialsError => e
    session[:error] = e.message
    @username = username
    erb :login
  end
end

# Render signup page
get '/signup' do
  logout
  erb :signup
end

# Register user
post '/users' do
  username = params[:username]
  password = params[:password]

  begin
    session[:user_id] = @users.create(username, password, @inventories)
    redirect '/inventories/user'
  rescue InsecurePasswordError, NonUniqueUsernameError => e
    session[:error] = e.message
    @username = username
    erb :signup
  end
end

# SEARCH ALL PLANTS

# Render form or plants list
get '/plants' do
  @title = "Search"
  @subtitle = "Search thousands of plants using any number of filters."

  filters = extract_filters(params)

  return redirect append_page(request.fullpath) unless params.key?(:page)

  @page = retrieve_page_number(params[:page])
  @pagination_pages = pagination_pages(@page)

  begin
    @plants_list = @plants.search_all(filters,
                                      inventory_id: @user_inventory_id,
                                      page: @page)
    erb :plants
  rescue PG::UndefinedColumn
    session[:error] = "You provided a filter that doesn't exist. "\
                      "Only use the provided filters for searching."
    erb :'forms/search'
  end
end

# VIEW SINGULAR PLANTS

# Render a singular plant with the given `id`
get '/plants/:id' do
  begin
    @plant = @plants.find_by_id(params["id"], inventory_id: @user_inventory_id)
  rescue NoPlantFoundError => e
    session[:error] = e.message
    status 400
  end

  erb :plant
end

# INVENTORY

# Render an inventory with the given `inventory_id`
# rubocop:disable Metrics/BlockLength
get '/inventories/:inventory_id' do
  inventory_id = params['inventory_id']
  @inventory = if inventory_id == 'user'
                 @user_inventory
               else
                 @inventories.find_by_id(inventory_id)
               end

  unless @inventory
    session[:error] =
      "No public inventory with the id '#{inventory_id}' exists."
    redirect '/community'
  end

  if @inventory.id == @user_inventory_id
    @title = "Your Inventory"
    @subtitle = "Browse plants saved in your inventory."
  else
    @title = "Inventory: #{@inventory.name}"
  end

  filters = extract_filters(params)

  return redirect append_page(request.fullpath) unless params.key?(:page)

  @page = retrieve_page_number(params[:page])
  @pagination_pages = pagination_pages(@page)

  begin
    @plants_list = @plants.search_all(filters,
                                      inventory_id: @inventory.id,
                                      inventory_only: true,
                                      page: @page)
    erb :plants
  rescue PG::UndefinedColumn
    session[:error] = "You provided a filter that doesn't exist. "\
                      "Only use the provided filters for searching."
    erb :'forms/search'
  end
end
# rubocop:enable Metrics/BlockLength

# Add a plant to a user's inventory
post '/inventories/user' do
  verify_uniqueness(@user_inventory_id, params["plant_id"]) do
    verify_quantity(params["quantity"]) do |quantity|
      plant_id = params["plant_id"].to_i
      inventory_id = @user_inventory_id
      @inventories.add_plant(plant_id, quantity, inventory_id)
      status 204
    end
  end
end

# Update quantity of plant in inventory
post '/inventories/user/:plant_id/update' do
  verify_in_inventory(@user_inventory_id, params["plant_id"]) do
    verify_quantity(params["quantity"]) do |quantity|
      plant_id = params["plant_id"].to_i
      @inventories.update_plant_quantity(plant_id, quantity, @user_inventory_id)
      status 204
    end
  end
end

# Delete plant from inventory (disregards faulty ids)
post '/inventories/user/:plant_id/delete' do
  verify_in_inventory(@user_inventory_id, params["plant_id"]) do
    plant_id = params["plant_id"].to_i
    @inventories.delete_plant(plant_id, @user_inventory_id)
    status 204
  end
end

# COMMUNITY

# Render a list of public inventories from the community
get '/community' do
  @title = "Community"
  inventory_name = params["inventory_name"] || ''
  owner_name = params["owner_name"] || ''
  min_plants = if params["min_plants"] == '' || !params["min_plants"]
                 1
               else
                 params["min_plants"].to_i
               end
  plant_id = params["plant_id"].to_i
  @inventories_list = @inventories.search_all(inventory_name, owner_name,
                                              min_plants, plant_id)
  erb :community
end

# SETTINGS

# Render the settings page
get '/settings' do
  @title = "Settings"
  erb :settings
end
