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

  context "GET /spaces" do
    it 'returns a list of spaces' do
      response = get("/spaces")

      expect(response.status).to eq(200)
      expect(response.body).to include "<h3>Book a Space</h3>"
      expect(response.body).to include "Happy meadows"
      expect(response.body).to include "A happy place"
      expect(response.body).to include "Scary fields"
      expect(response.body).to include "A scary field"
    end
  end
  
  context 'GET /login' do
    it "displays a login form" do
      response = get('/login')
      expect(response.status).to eq 200
      expect(response.body).to include('<h1>Login to MakersBnB</h1>')
      expect(response.body).to include('<form method="POST" action="/login_attempt">')
      expect(response.body).to include('<label for="email">Email Address:</label>')
      expect(response.body).to include('<input type="text" name="email" />')
      expect(response.body).to include('<label for="password">Password:</label>')
      expect(response.body).to include('<input type="password" name="password" />')
    end
  end

  context 'POST /login_attempt' do
    context 'when user submits valid credentials' do
      it "logs the user in" do
        response = post('/login_attempt', { email: "sam@email.com", password: "sampassword" })
        expect(response.status).to eq(302)
        follow_redirect!
        expect(last_request.path).to eq('/spaces')
        expect(last_request.env['rack.session'][:user]).to be_an_instance_of User
        expect(last_request.env['rack.session'][:user].username).to eq "usersam"
        expect(last_request.env['rack.session'][:user].id).to eq 1
      end
    end

    context 'when user submits invalid password' do
      it "displays error message" do
        response = post('/login_attempt', { email: "sam@email.com", password: "notthepassword" })
        expect(response.status).to eq(401)
        expect(response.body).to include('<h1>Login Denied</h1>')
        expect(response.body).to include('<a href="/login">Retry login here</a>')
      end
    end

    context 'when user submits invalid email' do
      it "displays error message" do
        response = post('/login_attempt', { email: "not_a_user@example.com", password: "sampassword" })
        expect(response.status).to eq(401)
        expect(response.body).to include('<h1>Login Denied</h1>')
        expect(response.body).to include('<a href="/login">Retry login here</a>')
      end
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

  context 'GET /requests' do
    it "gets all the requests made to a users' spaces" do
      post('/login_attempt', { email: "gary@email.com", password: "garypassword" })
      response = get('/requests')

      expect(response.body).to include 'Space ID: 2'
      expect(response.body).to include 'Space ID: 3'
    end

    it "gets all the requests made by a user" do
      post('/login_attempt', { email: "jack@email.com", password: "jackpassword" })
      response = get('/requests')

      expect(response.body).to include 'Space ID: 1'
      expect(response.body).to include 'Space ID: 2'
    end
  end

  context "GET /spaces/2" do
    it "Displays a space by ID with name & description" do
      response = get('/spaces/2')
      expect(response.status).to eq 200
      expect(response.body).to include("<h1>Scary fields</h1>") 
      expect(response.body).to include("A scary field") 
    end

    it "Displays available dates" do
      response = get('/spaces/2')
      expect(response.status).to eq 200
      expect(response.body).to include('<label for="date">Select a date:</label>')
      expect(response.body).to include('<select name="date">') 
      expect(response.body).to include('<option value="2023-03-16">2023-03-16</option>')
      expect(response.body).to include('<option value="2023-03-17">2023-03-17</option>')
      expect(response.body).to include('<option value="2023-03-18">2023-03-18</option>')
    end
  end

  context "GET /spaces/300 (invalid ID)" do
    it "redirects to the spaces page" do
      response = get('/spaces/300')
      expect(response.status).to eq 302
      follow_redirect!
      expect(last_request.path).to eq('/spaces')
    end
  end

  context 'GET /requests/:id' do
    it 'returns the correct request page' do
    response = get('/requests/2')

    expect(response.status).to eq 200
    expect(response.body).to include("<h1>Request for Happy meadows</h1>") 
    expect(response.body).to include("A happy place") 
    expect(response.body).to include('From: jack@email.com')
    expect(response.body).to include('Date: 2023-04-17') 
    end
  end
    # GET /spaces/300

    # expect(response.status).to eq 302
    # follow_redirect!
    # expect(last_request.path).to eq('/spaces')

end
