require 'sinatra/base'
require 'sinatra/reloader'
require_relative './lib/space'
require_relative './lib/spaces_repository'

#  DatabaseConnection.connect

class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    return erb(:index)
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