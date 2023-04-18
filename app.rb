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
    # user_record = UserRepository.new.find_by_email(params[:email]) 
    repo = UserRepository.new
    user_record = repo.find_by_email(params[:email])

    return deny_login if user_record.nil?
    # deny_login unless params[:password] == user_record.password

    if params[:password] == user_record.password
      session[:user] = user_record
      return redirect('/spaces')
    else
      deny_login
    end
  end

  def deny_login
    status 401
    return erb(:login_denied)
  end

  get '/spaces' do
    return erb(:spaces)
  end

end