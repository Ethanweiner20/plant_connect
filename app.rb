require 'bundler/setup'
require 'sinatra'
require 'tilt/erubis'
require_relative 'lib/helpers'
require_relative 'lib/plants_storage'
require_relative 'lib/users'
require_relative 'lib/inventories'
require 'pry'

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
  # session.delete(:next_path)
  @users = Users.new(logger: logger)
  @user = @users.find_by_id(session[:user_id]) if session.key?(:user_id)
  @plants_storage = PlantsStorage.new(logger: logger)
  @inventories = Inventories.new(logger: logger)
  if @user
    @user_inventory = @inventories.find(@user["id"])
    @inventory_id = @user_inventory.id
  end
end

PROTECTED_ROUTES = ['/inventory*', '/community*', '/settings']

PROTECTED_ROUTES.each do |route|
  before route do
    protected!
  end
end

# INDEX

get '/' do
  redirect '/plants'
end

# AUTHENTICATION

def logout
  session.delete(:user_id)
end

post '/logout' do
  logout
  redirect '/login'
end

# Login

get '/login' do
  logout
  erb :'pages/login'
end

post '/login' do
  username = params[:username]
  password = params[:password]

  begin
    user_id = @users.authenticate(username, password)
    session[:user_id] = user_id
    redirect session[:next_path]
  rescue InvalidLoginCredentialsError => e
    session[:error] = e.message
    @username = username
    erb :'pages/login'
  end
end

# Signup

get '/signup' do
  logout
  erb :'pages/signup'
end

post '/users' do
  username = params[:username]
  password = params[:password]

  begin
    user_id = @users.create(username, password, @inventories)
    session[:user_id] = user_id
    redirect '/inventory?page=1'
  rescue InsecurePasswordError, NonUniqueUsernameError => e
    session[:error] = e.message
    @username = username
    erb :'pages/signup'
  end
end

# SEARCH ALL PLANTS

# Render form or plants list
get '/plants' do
  @title = "Search"
  @subtitle = "Search for plants using any number of filters."

  filters = params.clone
  filters.delete(:page)

  if params.empty?
    erb :'forms/search'
  elsif !params.key?(:page)
    session[:error] = "No page was provided."
    erb :'forms/search'
  else
    @page = set_page_number
    @pagination_pages = pagination_pages(@page)
    begin
      @plants = @plants_storage.search_all(filters,
                                         inventory_id: @inventory_id,
                                         page: @page)
      erb(:'forms/search') + erb(:'components/plants', layout: nil)
    rescue PG::UndefinedColumn
      session[:error] = "You provided a filter that doesn't exist. "\
                        "Only use the provided filters for searching."
      erb(:'forms/search')
    end
  end
end

# VIEW SINGULAR PLANTS

get '/plants/:id' do
  begin
    @plant = @plants_storage.find_by_id(params["id"])
  rescue NoPlantFoundError => e
    session[:error] = e.message
    status 400
  end

  erb :'pages/plant'
end

# INVENTORY

# Manage inventory
get '/inventory' do
  redirect '/login' unless @user

  @title = "Inventory: #{@user_inventory.name}"
  @subtitle = "Browse plants saved in your inventory."

  filters = params.clone
  filters.delete(:page)

  if !params.key?(:page)
    session[:error] = "No page was provided."
    erb :'forms/search'
  else
    @page = set_page_number
    @pagination_pages = pagination_pages(@page)

    begin
      @plants = @plants_storage.search_all(filters,
        inventory_id: @inventory_id,
        inventory_only: true,
        page: @page)
      erb(:'forms/search') + erb(:'components/plants', layout: nil)
    rescue PG::UndefinedColumn
      session[:error] = "You provided a filter that doesn't exist. "\
                        "Only use the provided filters for searching."
      erb(:'forms/search')
    end
  end
end

# [AJAX] Add a plant to a user's inventory
post '/inventory' do
  verify_uniqueness(@inventory_id, params["id"]) do
    verify_quantity(params["quantity"]) do |quantity|
      plant_id = params["id"].to_i
      quantity = params["quantity"].to_i
      inventory_id = @inventory_id
      @inventories.add_plant(plant_id, quantity, inventory_id)
      status 204
    end
  end
end

# [AJAX] Update quantity of plant in inventory
post '/inventory/:id/update' do
  verify_in_inventory(@inventory_id, params["id"]) do
    verify_quantity(params["quantity"]) do |quantity|
      plant_id = params["id"].to_i
      quantity = params["quantity"].to_i
      inventory_id = @inventory_id
      @inventories.update_plant_quantity(plant_id, quantity, inventory_id)
      status 204
    end
  end
end

# [AJAX] Delete plant from inventory
# Note: Simply disregards faulty ids
post '/inventory/:id/delete' do
  verify_in_inventory(@inventory_id, params["id"]) do
    plant_id = params["id"].to_i
    inventory_id = @inventory_id
    @inventories.delete_plant(plant_id, inventory_id)
    status 204
  end
end

# COMMUNITY

get '/community' do
  @title = "Community"
  redirect '/login' unless @user
  erb :'pages/community'
end

# SETTINGS

get '/settings' do
  @title = "Settings"
  erb :'pages/settings'
end

# CUSTOM PLANTS

# Add plant to a user's custom plants
# get '/users/plants/new' do
# end

# post '/users/plants' do
# end

# # Edit a custom plant
# get '/users/plants/:id/edit' do
# end

# post '/users/plants/:id' do
# end
