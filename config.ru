require 'bundler/setup'

require './app'
require './repositories'

map '/' do
  use Rack::Session::Cookie, {
    secret: ENV['SESSION_SECRET'] || '12h12u8JKBVss84',
    httponly: true, 
    :cache_control => "public,max-age=#{365 * 24 * 3600}"
  }
  run Sinatra::Application
end
