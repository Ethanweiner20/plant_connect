require 'simplecov'

ENV["RACK_ENV"] = "test"

require 'minitest/autorun'
require "minitest/reporters"

Minitest::Reporters.use!

require "rack/test"
require_relative './test_routes.rb'
require_relative './test_image_search.rb'
require_relative './test_usda_plants_api.rb'
