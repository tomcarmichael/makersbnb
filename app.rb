require 'sinatra/base'
require 'sinatra/reloader'
require_relative './lib/user_repository'

class Application < Sinatra::Base
  enable :sessions

  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    return erb(:index)
  end

  get '/login' do
    return erb(:login)
  end

  post '/login_attempt' do
    repo = UserRepository.new
    user_record = repo.find_by_email(params[:email])

    return deny_login unless user_record && params[:password] == user_record.password

    session[:user] = user_record
    return redirect('/spaces')
  end

  def deny_login
    status 401
    return erb(:login_denied)
  end

  get '/spaces' do
    return erb(:spaces)
  end

end