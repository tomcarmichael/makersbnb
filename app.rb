require 'sinatra/base'
require 'sinatra/reloader'
require 'space'

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
    space = Space.new
    space.name=params['name']
    space.description=params['description']
    space.price_per_night=params['price']
    start_date = Date.parse(params['start_date'])
    end_date = Date.parse(params['start_date'])
    space.available_dates=(start_date..end_date).to_a
    space.owner_id = 1

    repo = SpacesRepository.new
    repo.create(space)
    
    return erb(:space_posted)
  end
end