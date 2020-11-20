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

def clear_flash(session)
  session[:current].delete(:flash) if session[:current] && session[:current][:flash]
end

before do
  @storage = DatabasePersistence.new()
end

after do
  @storage.disconnect
  clear_flash(session) if request.path_info[-1] == '/'
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
  # send_file 'index.html'
  erb :index
end

# post '/add/ingredient' do
#   request.body.rewind
#   # puts(JSON.parse(request.body.read).to_json)
#   json JSON.parse(request.body.read).to_json
# end

post '/login' do
  username = escape_html(params[:username])
  password = escape_html(params[:password])

  session[:current] ||= {}

  logged_in = verify_credentials(username, password)

  return unless logged_in

  session[:user_id] = @storage.get_user_id(username) || nil
  # p session[:user_id]
  session[:username] = username
  response = {}

  session[:current][:loggedIn] = logged_in
  session[:current][:person] = {'name' => username, :selectedIngredients => @storage.get_ingredients(username)}
  # response['person'] = {'name' => username, 'selectedIngredients' => []}
  session[:current][:flash] = {'message' => 'Logged in!', 'action' => 'Happy Thanksgiving week!'}

  # @storage.add_ingredient(params[:add_ingredient], session[:user_id])

  # json response.to_json
  redirect '/'
end

post '/add/ingredient' do
  ingredient_name = params[:ingredient]
  response = {}
  if @storage.get_ingredients(session[:username]).count >= 5
    session[:current][:flash] = {'message' => 'Max ingredients selected!', 'action' => 'If you haven\'t added random ingredients, do that!'}
    redirect '/'
  end

  session[:current] ||= {}

  if @storage.add_ingredient(ingredient_name, session[:user_id])
    session[:current][:person][:selectedIngredients] = @storage.get_ingredients(session[:username])
    # response['ingredient'] = {"name" => ingredient_name};
    session[:current][:flash] = {'message' => 'Ingredient added!', 'action' => 'You can add more!'}
  else
    session[:flash] = {'message' => 'Ingredient could not be added!', 'action' => 'You can try again!'}
  end

  # json response.to_json
  redirect '/'
  # erb :index
end

post '/create/account' do
  username = params[:username]
  password = params[:password]
  password2 = params[:password2]

  session[:current] ||= {}

  if !@storage.username_available?(username)

    session[:current][:flash] = {message: "Username is unavailable!", action: "try a different username."}
    redirect '/'
  end

  if password != password2
    session[:current][:flash] = {message: "Passwords must match!", action: "try again"}
    redirect '/'
  end

  @storage.add_user(username, BCrypt::Password.create(password))

  session[:current][:flash] = {message: 'You may now log in!', action: ''}
  redirect '/'
end

get '/logout' do
  session.clear

  redirect '/'
end

post '/add/random/ingredients' do
  response = {}
  session[:current] ||= {}

  session[:current][:flash] = {message:" here are your random ingredients!", action: "now, you can make a dish"};

  @storage.get_random_ingredients(session[:username])

  session[:current][:person][:selectedIngredients] = @storage.get_ingredients(session[:username])
  redirect '/'
end