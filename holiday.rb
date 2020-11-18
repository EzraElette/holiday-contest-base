require 'erubis'
require 'sinatra'
require 'bcrypt  '

configure do
  enable :sessions
  set :session_secret, 'secret'
end
