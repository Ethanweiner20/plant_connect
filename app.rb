require 'bundler/setup'

require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

get '/' do
  erb :home
end
