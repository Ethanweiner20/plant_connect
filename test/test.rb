require 'simplecov'

ENV["RACK_ENV"] = "test"

require 'minitest/autorun'
require "minitest/reporters"

Minitest::Reporters.use!

require "rack/test"
require_relative './test_routes'
require_relative './test_image_search'
require_relative './test_plants_api'
