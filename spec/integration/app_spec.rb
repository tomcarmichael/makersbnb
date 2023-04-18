require "spec_helper"
require "rack/test"
require_relative '../../app'
require 'json'

def reset_tables
  sql = File.read('spec/seeds/seeds.sql')
  connection = PG.connect({host: '127.0.0.1', dbname: 'makersbnb_test'})
  connection.exec(sql)
end

describe Application do
  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods

  before(:each) do 
    reset_Recipes_table
  end

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }

  # Write your integration tests below.
  # If you want to split your integration tests
  # accross multiple RSpec files (for example, have
  # one test suite for each set of related features),
  # you can duplicate this test file to create a new one.


  context 'GET /' do
    it 'should get the homepage' do
      response = get('/')

      expect(response.status).to eq(200)
    end
  end

  context 'GET /spaces/new' do
    it 'should get the form to make a new space' do
      response = get('/spaces/new')

      expect(response.status).to eq 200
      expect(response.body).to include '<h1>List a space'
    end

    it 'sumbits the form and adds to the database' do
      response = post('/spaces', name: 'Sunny Shores', description: 'A sunny shore', price: 8.49, start_date: '{2024-4-16}', end_date: '{2024-4-18}', owner_id: 2)
      
      repo = SpacesRepository.new
      new_space = repo.all.last
      expect(new_space.name).to eq 'Sunny Shores'
      expect(new_space.owner_id).to eq 2
      expect(new_space.available_dates.length).to eq 3
      expect(new_space.available_dates[1]).to eq Date.parse('2024-4-17')
    end
  end
end
