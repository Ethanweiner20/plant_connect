require 'uri'
require 'net/http'
require 'json'
require 'pry'

# Stores the data for a given plant
class Plant
  attr_reader :data

  IMAGE_SEARCH_URI = "https://commons.wikimedia.org/w/api.php"

  WIKIMEDIA_IMAGE_REQUEST_PARAMS = {
    action: 'query',
    generator: 'images',
    prop: 'imageinfo',
    gimlimit: '1',
    redirects: '1',
    iiprop: 'url',
    format: 'json'
  }

  def initialize(data)
    @data = data
    @image_src = nil
  end

  def [](key)
    data[key]
  end

  # Provides a representative color of the plant
  # Used in various display areas
  def color; end

  def find_image_source(titles)
    uri = URI(IMAGE_SEARCH_URI)
    params = WIKIMEDIA_IMAGE_REQUEST_PARAMS.dup
    params[:titles] = titles.join('|')
    uri.query = URI.encode_www_form(params)
    response = Net::HTTP.get_response(uri)
    if response.is_a?(Net::HTTPSuccess)
      extract_src(response)
    end
  end

  # Find a Wikipedia image for the plant
  def image_src
    find_image_source([data["Scientific Name"], data["Common Name"]])
  end

  def extract_src(response)
    query = JSON.parse(response.body)["query"]
    return query["pages"].values[0]["imageinfo"][0]["url"] if query
  end
end
