require_relative 'plant'
require_relative 'plants_storage'
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

def append_page(path)
  path.include?('?') ? path + '&page=1' : path + '?page=1'
end

def data_path
  ENV["RACK_ENV"] == "test" ? "#{ROOT}/test/data" : "#{ROOT}/data"
end

def file_path(file_name)
  "#{data_path}/#{file_name}"
end

def protected!
  if @user
    session.delete(:next_path)
    return
  end
  
  session[:error] = "You must be logged in to do that."

  # Store the requested path
  session[:next_path] = request.fullpath
  redirect "/login" unless @user
end

# Input Validation

def valid_quantity?(quantity)
  quantity.to_i.to_s == quantity && quantity.to_i >= 0
end

def verify_quantity(quantity)
  if valid_quantity?(quantity)
    yield(quantity.to_i)
  else
    status 400
    "Quantity must be a non-negative integer."
  end
end

def verify_in_inventory(inventory_id, plant_id)
  if @plants_storage.search_inventory(inventory_id, { "plants.id" => plant_id }).empty?
    status 400
    "This plant is not in your inventory."
  else
    yield
  end
end

def verify_uniqueness(inventory_id, plant_id)
  if @plants_storage.search_inventory(inventory_id, { "plants.id" => plant_id }).empty?
    yield
  else
    status 400
    "This plant is already in your inventory."
  end
end

# Pagination helpers

def set_page_number(page_string)
  if valid_page?(page_string)
    page_string.to_i
  else
    session[:error] = "Invalid page number '#{page_string}'. "\
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
