require 'uri'
require 'net/http'
require 'json'

# Stores the data for a given plant
class Plant
  attr_reader :data

  WIKIMEDIA_IMAGE_REQUEST_PARAMS = {
    action: 'query',
    generator: 'images',
    prop: 'imageinfo',
    ginlimit: '1',
    redirects: '1',
    iiprop: 'timestamp|user|userid|comment|canonicaltitle|url|size|dimensions|\
    sha1|mime|thumbmime|mediatype|bitdepth',
    format: 'json'
  }

  def initialize(data)
    @data = data
  end

  def [](key)
    data[key]
  end

  # Provides a representative color of the plant
  # Used in various display areas
  def color; end

  # Find a Wikipedia image for the plant
  def image_src
    uri = URI("https://commons.wikimedia.org/w/api.php")
    params = WIKIMEDIA_IMAGE_REQUEST_PARAMS.dup
    params[:titles] = data[:scientific_name] || data[:common_name]
    uri.query = URI.encode_www_form(params)
    response = Net::HTTP.get_response(uri)
    if response.is_a?(Net::HTTPSuccess)
      extract_src(response)
    end
  end

  def extract_src(response)
    json = JSON.parse(response.body)
    json["query"]["pages"].values[0]["imageinfo"][0]["url"]
  end
end
