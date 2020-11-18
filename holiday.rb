require 'erubis'
require 'sinatra'
require 'bcrypt'

configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
end

get '/' do
  send_file 'index.html'
end
