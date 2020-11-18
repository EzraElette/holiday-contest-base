require 'erubis'
require 'sinatra'
require 'sinatra/json'
require 'bcrypt'

configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
end

get '/' do
  send_file 'index.html'
end


post '/' do
  obj = JSON.parse request.body.read

  json(obj, :encoder => :to_json, :content_type => :json)
end