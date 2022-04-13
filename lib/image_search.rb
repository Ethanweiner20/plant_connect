require 'uri'
require 'net/http'
require 'json'

class ImageSearch
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

  def self.find_image_source(titles)
    uri = URI(IMAGE_SEARCH_URI)
    params = WIKIMEDIA_IMAGE_REQUEST_PARAMS.dup
    params[:titles] = titles.join('|')
    uri.query = URI.encode_www_form(params)
    response = Net::HTTP.get_response(uri)
    return unless response.is_a?(Net::HTTPSuccess)
    extract_src(response)
  end

  def self.extract_src(response)
    query = JSON.parse(response.body)["query"]
    return unless query && query["pages"]
    query["pages"].values[0]["imageinfo"][0]["url"]
  end
end
