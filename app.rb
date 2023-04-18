require 'sinatra/base'
require 'sinatra/reloader'
require_relative './lib/user_repository'
require_relative './lib/space'
require_relative './lib/spaces_repository'

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


  get '/spaces/new' do
    
    return erb(:list_space_new)
  end

  post '/spaces' do
    repo = SpacesRepository.new
    space = Space.new

    space.name=params['name']
    space.description=params['description']
    space.price_per_night=params['price']
    start_date = Date.parse(params['start_date'])
    end_date = Date.parse(params['end_date'])
    space.available_dates = (start_date..end_date).to_a
    # Needs to be changed to session ID when available
    space.owner_id = 2

    repo.create(space)
    
    return redirect '/'
  end
end