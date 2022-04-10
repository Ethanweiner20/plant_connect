require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader'
also_reload('lib/*.rb')

require 'tilt/erubis'
require_relative 'lib/plant.rb'
require_relative 'lib/usda_plants_api.rb'

configure do
  enable :sessions
  set :session_secret, "secret"
end

# HELPERS

get '/' do
  redirect '/plants'
end

# AUTHENTICATION

get '/signup' do
end

post '/users' do
  redirect '/plants'
end

get '/login' do
end

get '/users' do
  redirect '/plants'
end

# SEARCH ALL PLANTS

# Search for plants and render results
get '/plants' do
  SEARCH_LIMIT = settings.development? ? 500 : 10000

  if request.xhr? && params.values.all?(&:empty?)
    erb(:alert, layout: nil, locals: { message: "No filters were provided." })
  elsif request.xhr?
    @page = params[:page]

    filters = params.clone
    filters.delete(:page)

    result = USDAPlants.search(filters, max_index: SEARCH_LIMIT)
    @plants = result[:plants]

    @last_index = result[:last_index]

    erb(:plants, layout: params[:inline] ? :layout : nil)
  else
    erb :search
  end
end

# VIEW SINGULAR PLANTS

get '/plants/:scientific_name' do
  @plant = USDAPlants.find(params[:scientific_name])

  erb :plant
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

# Inventories

# Manage inventories
get '/users/:username/inventories/new' do
end

post '/users/:username/inventories' do
end

# Render list of plants in user's inventory
get '/users/:username/inventories/:inventory_name' do
  erb :inventory
end

# Add a plant to a user's inventory
post '/users/:username/inventories/:inventory_name' do
end

# SETTINGS

get '/settings' do
  erb :settings
end
