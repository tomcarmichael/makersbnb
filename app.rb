require 'sinatra/base'
require 'sinatra/reloader'
require_relative 'lib/spaces_repository'
require_relative 'lib/database_connection'

class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    also_reload 'lib/spaces_repository'
    also_reload 'lib/user_repository'
  end

  get '/' do
    return erb(:index)
  end

  get '/spaces' do
    @spaces = SpacesRepository.new.all
    return erb(:spaces)
  end
end