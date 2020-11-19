require 'erubis'
require 'sinatra'
# require 'sinatra/reloader'
require 'sinatra/json'
require 'bcrypt'
require 'json'
require_relative 'database_persistence.rb'

configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
end

configure(:development) do
  require "sinatra/reloader"
  also_reload "database_persistence.rb"
end

before do
  @storage = DatabasePersistence.new()
end

after do
  @storage.disconnect
end

def escape_html(html)
  Rack::Utils.escape_html(html)
end

def verify_credentials(username, password)
  password_hash = @storage.get_user_pass(username)

  BCrypt::Password.new(password_hash) == password
end

def signed_in?
  return false unless user_list
  user_list.include?(session[:username])
end

get '/' do
  send_file 'index.html'
end

# post '/add/ingredient' do
#   request.body.rewind
#   # puts(JSON.parse(request.body.read).to_json)
#   json JSON.parse(request.body.read).to_json
# end

post '/login' do
  username = escape_html(params[:username])
  password = escape_html(params[:password])

  logged_in = verify_credentials(username, password)

  return unless logged_in
    # session[:user_id] = @storage.get_user_id(username) || nil

  response = {}

  response['loggedIn'] = logged_in

  response['person'] = {'name' => username, 'selectedIngredients' => []}
  response['flash'] = {'message' => 'Logged in!', 'action' => 'Happy Thanksgiving week!'}

  # @storage.add_ingredient(params[:add_ingredient], session[:user_id])

  json response.to_json
end

post '/add/ingredient' do
  ingredient_name = params[:ingredient]
  response = {}
  # response['person'] = {'selectedIngredients' => [{'name' => ingredient_name}]}
  response['ingredient'] = {"name" => ingredient_name};
  response['flash'] = {'message' => 'Ingredient(s) added!', 'action' => 'You can add more!'}
  # response[:ingredient] = ingredient_name
  json response.to_json
  # redirect '/'
  # @storage.add_ingredient(ingredient_name, session[:user_id])
end

post '/create/account' do
#
end

post '/add/random/ingredients' do
  response = {}

  response['randomIngredients'] = [{name: "potato"}, {name: "yam"}, {name: "cranberry"}]

  json response.to_json
end