require 'sinatra/base'
require 'sinatra/reloader'
require_relative './lib/user_repository'
require_relative './lib/space'
require_relative './lib/spaces_repository'
require_relative './lib/request_repository'
require_relative './lib/request'
require_relative './lib/helpers'

class Application < Sinatra::Base
  enable :sessions

  configure :development do
    register Sinatra::Reloader
    also_reload 'lib/spaces_repository'
    also_reload 'lib/user_repository'
    also_reload 'lib/request_repository'
    also_reload 'lib/helpers'
  end

  get '/' do
    @title = 'MakersBnB'
    return erb(:index)
  end

  get '/login' do
    @title = 'MakersBnB - Login'
    return erb(:login)
  end

  post '/login_attempt' do
    repo = UserRepository.new
    user_record = repo.find_by_email(params[:email])

    return deny_login unless user_record && params[:password] == user_record.password

    session[:user] = user_record
    return redirect('/spaces')
  end

  get '/spaces' do
    @title = 'MakersBnB - Spaces'
    @spaces = SpacesRepository.new.all
    return erb(:spaces)
  end

  get '/spaces/new' do
    @title = 'MakersBnB - List a space'
    return erb(:list_space_new)
  end

  post '/spaces' do
    repo = SpacesRepository.new
    space = Space.new

    space.name = params['name']
    space.description = params['description']
    space.price_per_night = params['price']
    start_date = Date.parse(params['start_date'])
    end_date = Date.parse(params['end_date'])
    space.available_dates = (start_date..end_date).to_a
    # Needs to be changed to session ID when available
    space.owner_id = 2

    repo.create(space)

    return redirect '/'
  end

  get '/requests' do
    @title = 'MakersBnB - Requests'
    repo = RequestRepository.new
    @requests = repo.find_requests_for_user(session[:user].id)
    @requests_by_me = repo.find_by_requester_id(session[:user].id)

    return erb(:requests)
  end

  get '/spaces/:id' do
    repo = SpacesRepository.new
    @space = repo.find_by_id(params[:id])

    return redirect('/spaces') unless @space

    erb(:space)
  end

  post '/logout' do
    session[:user] = nil
    return redirect('/spaces')
  end

  post '/spaces/:id' do
    request = Request.new
    repo = RequestRepository.new

    request.space_id = params[:id]
    request.requester_id = session[:user].id
    request.date = Date.parse(params[:date])
    request.status = 'requested'

    repo.create(request)

    return redirect('/spaces')
  end

  get '/requests/:id' do
    repo = RequestRepository.new
    @request_data = repo.find_request_info_by_id(params[:id])
    return erb(:single_request)
  end

  post '/deny_request' do
    repo = RequestRepository.new
    repo.reject_request(params[:request_id])
    return redirect('/requests')
  end

  helpers do
    def current_page?(path = '')
      request.path_info == '/' + path
    end

    def deny_login
      status 401
      erb(:login_denied)
    end
  end
end
