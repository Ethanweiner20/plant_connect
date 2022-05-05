require_relative 'plant'
require_relative 'plants_storage'
require 'yaml'
require 'bcrypt'
require 'bundler/setup'
require 'sinatra'

ROOT = File.expand_path('..', __dir__)

# VIEW HELPERS

helpers do
  def generate_attribute_group(group_name, plant)
    list_items = ATTRIBUTES[group_name].map do |attribute|
      generate_attribute_item(attribute, plant)
    end
    "<ul>#{list_items.join('')}</ul>"
  end

  def generate_attribute_item(attribute, plant)
    value = plant[attribute]
    attribute_name = attribute.split('_').join(' ')
    "<li>#{attribute_name}: <strong>#{value}</strong></li>" if value
  end
end

# ROUTE HELPERS

def data_path
  ENV["RACK_ENV"] == "test" ? "#{ROOT}/test/data" : "#{ROOT}/data"
end

def file_path(file_name)
  "#{data_path}/#{file_name}"
end

def search_inventory(id)
  return unless @user
  @inventory["plants"].find do |plant|
    plant[:id] == id
  end
end

def protected!
  return if @user
  session[:error] = "You must be logged in to do that."
  redirect '/login' unless @user
end

# Input Validation

def valid_quantity?(quantity)
  quantity.to_i.to_s == quantity && quantity.to_i >= 0
end

def find_user(username, password)
  users = YAML.load_file(file_path('users.yml'))
  return unless users.key?(username)
  user = users[username]
  return user if BCrypt::Password.new(user["hash"]) == password
end

def verify_quantity(quantity)
  if valid_quantity?(quantity)
    yield(quantity.to_i)
    status 204
  else
    status 400
    "Quantity must be a non-negative integer."
  end
end

def verify_in_inventory(id)
  if !search_inventory(id)
    status 400
    "This plant is not in your inventory."
  else
    yield
  end
end

def verify_uniqueness(id)
  if !search_inventory(id)
    yield
  else
    status 400
    "This plant is already in your inventory."
  end
end

# Pagination helpers

def set_page_number
  if valid_page?(params[:page])
    params[:page].to_i
  else
    session[:error] = "Invalid page number '#{params[:page]}'. "\
                      "Showing page 1 instead."
    1
  end
end

def pagination_pages(current_page_number, num_pages: 4)
  multiplier = (current_page_number - 1) / num_pages
  start = (multiplier * num_pages) + 1
  (start...start + num_pages).to_a
end

def valid_page?(page_string)
  page_number = page_string.to_i
  page_number.to_s == page_string && page_number >= 1
end

def link_to_page(page_number)
  current_path = request.fullpath
  current_path.gsub(/page=\d+/, "page=#{page_number}")
end

# Search helpers

def mix_in_inventory(plants)
  plants.map do |plant|
    inventory_plant = search_inventory(plant.id)
    if inventory_plant
      InventoryPlant.new(inventory_plant[:id],
                         @plants_storage,
                         quantity: inventory_plant[:quantity],
                         data: plant.data)
    else
      plant
    end
  end
end

def render_search_results(filters, page: 1)
  result = @plants_storage.search(filters, page: page)
  @plants_storage = mix_in_inventory(result)

  erb(:'components/plants', layout: nil)
end

def resolve_plant(id)
  plant = search_inventory(id)

  if plant
    InventoryPlant.new(plant[:id], @plants_storage, quantity: plant[:quantity])
  else
    @plants_storage.find_by_id(id)
  end
end

# Render the plants from the inventory using optional `filters`
def render_inventory(filters: nil, page: 1)
  @plants_storage = @inventory["plants"].map do |plant|
    InventoryPlant.new(plant[:id], @plants_storage, quantity: plant[:quantity])
  end

  if filters
    @plants_storage = @plants_storage.select do |plant|
      @plants_storage.match?(plant.data, filters)
    end
  end

  erb(:'components/plants', layout: nil)
end
