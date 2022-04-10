require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader'
also_reload('lib/*.rb')

require 'tilt/erubis'
require_relative 'lib/plant.rb'
require_relative 'lib/usda_plants_api.rb'
require 'yaml'

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
  users.key?(username) && users[username] == password
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

def render_plant_list(wrap_layout: false)
  search_limit = settings.development? ? 500 : 10000

  filters = params.clone
  filters.delete(:page)

  result = USDAPlants.search(filters, max_index: search_limit)
  @plants = result[:plants]

  @last_index = result[:last_index]

  erb(:plants, layout: wrap_layout ? :layout : nil)
end

# Render form or plants list
get '/plants' do
  if request.xhr? && params.values.all?(&:empty?)
    erb(:alert, layout: nil, locals: { message: "No filters were provided." })
  elsif request.xhr? || params[:wrap_layout]
    render_plant_list(wrap_layout: params[:wrap_layout])
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

# Manage inventory
get '/inventory' do
  erb :inventory
end

# Add a plant to a user's inventory
post '/inventory' do
end

# COMMUNITY

get '/community' do
  erb :community
end

# SETTINGS

get '/settings' do
  erb :settings
end
