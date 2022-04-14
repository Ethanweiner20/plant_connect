require 'bundler/setup'
require 'sinatra'

# Reloading
if development?
  require 'sinatra/reloader'
  also_reload('lib/*.rb')
end

require 'tilt/erubis'
require_relative 'lib/helpers.rb'

# CONFIGURATION

configure do
  enable :sessions
  set :session_secret, "secret"
  set :erb, escape_html: true
end

# CONSTANTS

ATTRIBUTES = {
  taxonomy: %w(Class Order Family Genus Species),
  timing: %w(Duration BloomPeriod ActiveGrowthPeriod GrowthRate Lifespan),
  growth_requirements: %w(DroughtTolerance ShadeTolerance FireRestistance
                       FertilityRequirement),
  reproduction: %w(ResproutAbility SeedSpreadRate),
  physical_characteristics: %w(MatureHeight GrowthHabit GrowthForm
                            FoliageTexture),
  colors: %w(FoliageColor FlowerColor FruitColor)
}

# FILTERS

before do
  @user = session[:user]
  @inventory = @user ? @user["inventory"] : nil
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
  session.delete(:user)
end

post '/logout' do
  logout
  redirect '/login'
end

get '/login' do
  logout
  erb :'pages/login'
end

post '/login' do
  username = params[:username]
  password = params[:password]

  user = authenticate(username, password)
  if user
    session[:user] = user
    redirect '/inventory'
  else
    session[:error] = "Invalid username or password."
    @username = username
    erb :'pages/login'
  end
end

# SEARCH ALL PLANTS

# Render form or plants list
get '/plants' do
  @title = "Search"
  @subtitle = "Search for plants using any number of filters."

  if params.empty?
    erb :'forms/search'
  elsif params.values.all?(&:empty?)
    session[:error] = "No filters were provided."
    erb :'forms/search'
  else
    filters = params.clone
    filters.delete(:page)
    erb(:'forms/search') + render_search_results(filters)
  end
end

# VIEW SINGULAR PLANTS

get '/plants/:id' do
  begin
    @plant = resolve_plant(params["id"])
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

  @title = "Inventory"
  @subtitle = "Browse plants saved in your inventory."

  if params.empty? || params.values.all?(&:empty?)
    erb(:'forms/search') + render_inventory
  else
    filters = params.clone
    filters.delete(:page)
    erb(:'forms/search') + render_inventory(filters: filters)
  end
end

# [AJAX] Add a plant to a user's inventory
post '/inventory' do
  verify_uniqueness(params["id"]) do
    verify_quantity(params["quantity"]) do |quantity|
      plant = { id: params["id"], quantity: quantity }
      @inventory["plants"].unshift(plant)
    end
  end
end

# [AJAX] Update quantity of plant in inventory
post '/inventory/:id/update' do
  verify_in_inventory(params["id"]) do |_quantity|
    verify_quantity(params["quantity"]) do |quantity|
      plant_to_update = search_inventory(params["id"])
      plant_to_update[:quantity] = quantity
    end
  end
end

# [AJAX] Delete plant from inventory
# Note: Simply disregards faulty ids
post '/inventory/:id/delete' do
  @inventory["plants"].delete_if do |plant|
    plant[:id] == params["id"]
  end

  status 204
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

# SIGNUP

# get '/signup' do
#   # Temporary
#   redirect '/login'
#   logout
#   erb :signup
# end

# def strong_password?(password)
#   password =~ /.{8,}/ && password =~ /[A-Z]/ && password =~ /[0-9]/
# end

# def valid_signup_credentials?(username, password, users)
#   !users.key?(username) && strong_password?(password)
# end

# post '/users' do
#   redirect '/inventory'
# end
