require "sinatra"

require "httparty"


# this allows the server to be accessed more widely
# ある1つの防御を無効にするには、protectionにハッシュでオプションを指定します。
set :protection, :except => :frame_options
set :bind, "0.0.0.0"


# these constants are kept hidden from the client (user)
KEY = "66c2d36ee6611d5ff158f990ed054f76"
SECRET = "318f3c00a1c678ee"

# in case we want to do other things with the Flickr API
endpoint = "https://api.flickr.com/services/rest/?"

# global scope for our data to be retrieved
photos = {}

# helpers are just functions that we can use throughout the application
helpers do
  # this function grabs 10 recently uploaded photos from Flickr
  # however, the data that is returned does not include the image urls
  def get_photos
    response = HTTParty.get('https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=' + KEY + '&user_id=61133338%40N02&format=json&nojsoncallback=1&auth_token=72157668764913147-afcd4d3914b2f0a8&api_sig=6461b633c84966f4ef85adcffc08dfeb', format: :plain)

    # yep, JSON.parse, just like in JavaScript
    data = JSON.parse response

    photos = data["photos"]["photo"]

    # after getting the initial photo data which includes photo ids
    # we make a separate Flickr API request using the ids to get the photo urls
    photos.each do |photo|
      urls = get_url photo
      photo["files"] = urls
    end

    # in Ruby, by default, the last line of a function is returned
    photos
  end

  # our second request is separated into another function
  def get_url photo
    response = HTTParty.get('https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=' + KEY + '&user_id=61133338%40N02&format=json&nojsoncallback=1&auth_token=72157668764913147-afcd4d3914b2f0a8&api_sig=6461b633c84966f4ef85adcffc08dfeb&photo_id=' + photo[
      "id"], format: :plain)

    data = JSON.parse response

    data["sizes"]["size"]
  end
end

# this is the server that responds when a user makes a GET request
# to the root of the URL
get '/' do
  # this allows requests from other servers
  response['Access-Control-Allow-Origin'] = '*'

  # just like above, functions in Ruby end with a return statement
  # this is the final data we receive on the frontend (Glitch)
  get_photos.to_json
end
