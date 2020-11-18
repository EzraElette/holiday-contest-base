require 'erubis'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/json'
require 'bcrypt'
require 'json'

configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
end

def escape_html(html)
  Rack::Utils.escape_html(html)
end

def user_list
  # user_list = YAML.load_file(File.join(data_path, 'users.yml') )
  # user_list ? user_list : {}
  ["Rodney", "Ezra"]
end

def verify_credentials(username, password)
  # return false if user_list[username].nil? || password.empty?
  # BCrypt::Password.new(user_list[username]) == password

  user_list.include?(username) && password == 'password'
end

def signed_in?
  return false unless user_list
  user_list.include?(session[:username])
end

get '/' do
  send_file 'index.html'
end

post '/add/ingredient' do
  request.body.rewind
  # puts(JSON.parse(request.body.read).to_json)
  json JSON.parse(request.body.read).to_json
end

post '/login' do
  username = escape_html(params[:username])
  password = escape_html(params[:password])

  logged_in = verify_credentials(username, password)

  response = {}

  response['loggedIn'] = logged_in
  response['person'] = {'name' => 'Rodney', 'specialIngredients' => []}
  response['flash'] = {'message' => 'Logged in!', 'action' => 'Happy Thanksgiving week!'}
  json response.to_json
end


post '/create/account' do
#
end