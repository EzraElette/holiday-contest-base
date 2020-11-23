require 'erubis'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/json'
require 'bcrypt'
require 'json'
require_relative './database_persistence.rb'

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
  session[:current] ||= {}
end

after do
  @storage.disconnect
  clear_flash(session) if request.path_info[-1] != 'logout'
end

def require_signed_in_user
  if !session[:user_id]
    redirect '/'
  end
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

def set_flash(message, action)
  session[:current][:flash] = {'message' => message, 'action' => action}
end

get '/' do
  erb :index
end

get '/profile' do
  @name = session[:current][:person]['name']
  @photos = @storage.get_my_photos(session[:user_id])
  erb :profile
end

post '/login' do
  username = escape_html(params[:username])
  password = escape_html(params[:password])

  logged_in = verify_credentials(username, password)

  session[:current] ||= {}

  unless logged_in
    set_flash('Invalid username or password.', 'try again')
    redirect '/'
  end

  session[:user_id] = @storage.get_user_id(username) || nil

  session[:username] = username
  response = {}

  session[:current][:loggedIn] = logged_in
  session[:current][:person] = {'name' => username, :selectedIngredients => @storage.get_ingredients(username), :randomIngredients => @storage.get_random_ingredients(username) }

  set_flash('Logged in!', 'Happy Thanksgiving week!')

  redirect '/'
end

post '/add/ingredient' do
  require_signed_in_user

  ingredient_name = params[:ingredient]
  response = {}
  if @storage.get_ingredients(session[:username]).count >= 5
    set_flash('Max ingredients selected!', 'If you haven\'t added random ingredients, do that!')
    redirect '/'
  end

  session[:current] ||= {}

  if @storage.add_ingredient(ingredient_name, session[:user_id])
    session[:current][:person][:selectedIngredients] = @storage.get_ingredients(session[:username])

    set_flash('Ingredient added!', 'You can add more!')
  else
    set_flash('Ingredient could not be added!', 'You can try again!')
  end

  redirect '/'
end

post '/create/account' do
  username = params[:username]
  password = params[:password]
  password2 = params[:password2]

  session[:current] ||= {}

  if !@storage.username_available?(username)

    set_flash("Username is unavailable!", "try a different username.")
    redirect '/'
  end

  if password != password2
    set_flash("Passwords must match!", "try again")
    redirect '/'
  end

  @storage.add_user(username, BCrypt::Password.create(password))

  set_flash('You may now log in!', 'Account created!')
  redirect '/'
end

get '/logout' do
  require_signed_in_user

  session.clear

  redirect '/'
end

post '/add/random/ingredients' do
  require_signed_in_user

  response = {}
  session[:current] ||= {}

  if @storage.get_random_ingredients(session[:username]).count > 0
    set_flash("You already have your random ingredients!", "Start cooking.")
    redirect '/'
  end

  if @storage.get_ingredients(session[:username]).count < 5
    set_flash("Please add 5 ingredients first", "then you can get your random ingredients")
    redirect '/'
  end

  set_flash("here are your random ingredients!", "now, you can make a dish")

  @storage.add_random_ingredients(session[:username])

  session[:current][:person][:randomIngredients] = @storage.get_random_ingredients(session[:username])
  redirect '/'
end

get '/photos' do
  require_signed_in_user

  @photos = @storage.get_photos(session[:user_id])

  erb :photos
end


post '/add/image' do
  require_signed_in_user

  src = params[:imageData]
  name = params[:name]
  uploader = session[:user_id]

  @storage.add_image(src, name, uploader)

  set_flash('Image Uploaded', 'would you like to upload more?')

  redirect '/photos'
end

post '/vote' do
  id = request.body.read
  @storage.vote_for(id, session[:user_id])
  res = { message: 'You voted!', action: ''}
  json res.to_json
end