require 'spec_helper'
require 'rack/test'
require_relative '../../app'
require 'json'

def reset_tables
  sql = File.read('spec/seeds/seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'makersbnb_test' })
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
  let(:session_params) { { 'rack.session' => { user: double(:user_object) } } }
  let(:test_redirect_to_homepage) { 
    follow_redirect!
    expect(last_request.path).to eq('/')
  }
  let(:test_redirect_to_spaces_page) {
    follow_redirect!
    expect(last_request.path).to eq('/spaces')
  }

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

  context 'GET /spaces' do
    it 'returns a list of spaces' do
      response = get('/spaces', {}, session_params)

      expect(response.status).to eq(200)
      expect(response.body).to include '<h3>Book a Space</h3>'
      expect(response.body).to include 'Happy meadows'
      expect(response.body).to include 'A happy place'
      expect(response.body).to include 'Scary fields'
      expect(response.body).to include 'A scary field'
    end

    it "redirects user to home page if not logged in" do
      response = get('/spaces')
      expect(response.status).to eq(302)
      test_redirect_to_homepage
    end
  end

  context 'GET /login' do
    it 'displays a login form' do
      response = get('/login')
      expect(response.status).to eq 200
      expect(response.body).to include('<h1>Login to MakersBnB</h1>')
      expect(response.body).to include('<form method="POST" action="/login_attempt">')
      expect(response.body).to include('<label for="email">Email Address:</label>')
      expect(response.body).to include('<input type="text" name="email" id="email"/>')
      expect(response.body).to include('<label for="password">Password:</label>')
      expect(response.body).to include('<input type="password" name="password" id="password"/>')
    end
  end

  context 'POST /login_attempt' do
    context 'when user submits valid credentials' do
      it 'logs the user in' do
        response = post('/login_attempt', { email: 'sam@email.com', password: 'sampassword' })
        expect(response.status).to eq(302)
        test_redirect_to_spaces_page
        expect(last_request.env['rack.session'][:user]).to be_an_instance_of User
        expect(last_request.env['rack.session'][:user].username).to eq 'usersam'
        expect(last_request.env['rack.session'][:user].id).to eq 1
      end
    end

    context 'when user submits invalid password' do
      it 'displays error message' do
        response = post('/login_attempt', { email: 'sam@email.com', password: 'notthepassword' })
        expect(response.status).to eq(401)
        expect(response.body).to include('<h1>Login Denied</h1>')
        expect(response.body).to include('<a href="/login">Retry login here</a>')
      end
    end

    context 'when user submits invalid email' do
      it 'displays error message' do
        response = post('/login_attempt', { email: 'not_a_user@example.com', password: 'sampassword' })
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
      response = post('/spaces', name: 'Sunny Shores', description: 'A sunny shore', price: 8.49,
                                 start_date: '{2024-4-16}', end_date: '{2024-4-18}', owner_id: 2)

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
      post('/login_attempt', { email: 'gary@email.com', password: 'garypassword' })
      response = get('/requests')

      expect(response.body).to include 'Space ID: 2'
      expect(response.body).to include 'Space ID: 3'
    end

    it 'gets all the requests made by a user' do
      post('/login_attempt', { email: 'jack@email.com', password: 'jackpassword' })
      response = get('/requests')

      expect(response.body).to include 'Space ID: 1'
      expect(response.body).to include 'Space ID: 2'
    end

    it "redirects to the home page unless user is logged in" do
      response = get('/requests')
      expect(response.status).to eq(302)
      test_redirect_to_homepage
    end

  end

  context 'GET /spaces/:id' do
    it 'Displays a space by ID with name & description' do
      response = get('/spaces/2', {}, session_params)
      expect(response.status).to eq 200
      expect(response.body).to include('<h1>Scary fields</h1>')
      expect(response.body).to include('A scary field')
    end

    it 'Displays available dates' do
      response = get('/spaces/2', {}, session_params)
      expect(response.status).to eq 200
      expect(response.body).to include('<label for="date">Select a date:</label>')
      expect(response.body).to include('<select name="date" id="date">')
      expect(response.body).to include('<option value="2023-03-16">2023-03-16</option>')
      expect(response.body).to include('<option value="2023-03-17">2023-03-17</option>')
      expect(response.body).to include('<option value="2023-03-18">2023-03-18</option>')
    end

    it "redirects user to home page if not logged in" do
      response = get('/spaces/1')
      expect(response.status).to eq(302)
      test_redirect_to_homepage
    end

    context 'given an invalid ID in path' do
      it 'redirects to the spaces page' do
        response = get('/spaces/300', {}, session_params)
        expect(response.status).to eq 302
        test_redirect_to_spaces_page
      end
    end
  end




  context 'layout' do
    it 'displays a logout options via POST when user is logged in' do
      response = get('/spaces', {}, session_params)
      expect(response.body).to include('<form method="post" action="/logout"')
      expect(response.body).to include('<button type="submit" name="logout" class="link-button">Log out</button>')
    end
  end

  context 'POST /logout' do
    it 'redirects to home page' do
      response = post('/logout')
      expect(response.status).to eq(302)
      test_redirect_to_spaces_page
    end

    it 'logs the user out from session object' do
      response = post('/logout', {}, session_params)
      expect(response.status).to eq(302)
      follow_redirect!
      expect(last_request.env['rack.session'][:user]).to be_nil
    end
  end

  context 'GET /requests/:id' do
    it 'returns the correct request page' do
      # Request ID 2 is for a space Sam owns
      sam_user_object = UserRepository.new.find_by_id(1)
      response = get('/requests/2', {}, { 'rack.session' => { user: sam_user_object } })

      expect(response.status).to eq 200
      expect(response.body).to include('<h1>Request for Happy meadows</h1>')
      expect(response.body).to include('A happy place')
      expect(response.body).to include('From: jack@email.com')
      expect(response.body).to include('Date: 2023-04-17')
      expect(response.body).to include('Status: Requested')
    end

    it 'displays a button to deny request if user is the space owner' do
      sam_user_object = UserRepository.new.find_by_id(1)
      response = get('/requests/2', {}, { 'rack.session' => { user: sam_user_object } })
      expect(response.status).to eq(200)
      expect(response.body).to include('<form method="post" action="/deny_request">')
    end

    it 'redirects to homepage if logged in user is not the space owner for the request' do
      post('/login', { email: 'gary@email.com', password: 'garypassword' })
      response = get('/requests/2')
      expect(response.status).to eq(302)
    end

    it 'redirects to homepage if user is not logged in' do
      response = get('/requests/2')
      expect(response.status).to eq(302)
      test_redirect_to_homepage
    end

    it 'disables the buttons if the request isn\'t \'requested\'' do
      post('/login_attempt', { email: 'sam@email.com', password: 'sampassword' })
      response = get('/requests/6')
      expect(response.status).to eq(200)
      expect(response.body).to include('disabled>Deny Request</button')
      expect(response.body).to include('disabled>Accept Request</button')
    end
  end

  context 'POST /deny_request' do
    it "updates the request to 'rejected in the DB'" do
      request = RequestRepository.new.find_by_id(4)
      expect(request.status).to eq 'requested'
      response = post('/deny_request', { request_id: 4 })
      request = RequestRepository.new.find_by_id(4)
      expect(request.status).to eq 'rejected'
    end
    it 'redirects to /requests' do
      response = post('/deny_request', { request_id: 4 })
      expect(response.status).to eq(302)
      follow_redirect!
      expect(last_request.path).to eq('/requests')
    end
  end

  context 'POST /accept_request' do
    it "updates the request to 'confirmed' in the DB" do
      request = RequestRepository.new.find_by_id(4)
      expect(request.status).to eq 'requested'
      response = post('/accept_request', { request_id: 4 })
      request = RequestRepository.new.find_by_id(4)
      expect(request.status).to eq 'confirmed'
    end

    it 'redirects to /requests' do
      response = post('/accept_request', { request_id: 4 })
      expect(response.status).to eq(302)
      follow_redirect!
      expect(last_request.path).to eq('/requests')
    end

    it 'rejects all other requests for this space and date' do
      # Create Sam User object for test
      fake_user = UserRepository.new.find_by_id(1)
      # Make a new request for space 2 by user 'Sam'
      post('/spaces/2', {date: '2023-3-18'}, { 'rack.session' => { user: fake_user } })

      # Assert a new request has been made
      requests_for_space_2 = RequestRepository.new.find_by_space_id(2)
      expect(requests_for_space_2.length).to eq 2

      # Accept request 3
      post('/accept_request', { request_id: 3 })

      # Assert the request has been accepted
      accepted_request = RequestRepository.new.find_by_id(3)
      expect(accepted_request.status).to eq 'confirmed'

      # Assert the other request has been rejected
      rejected_request = RequestRepository.new.find_by_id(8)
      expect(rejected_request.status).to eq 'rejected'
    end

    it 'removes the date as an available date from the space' do
      post('/accept_request', { request_id: 3 })
      space = SpacesRepository.new.find_by_id(2)

      expect(space.available_dates).to eq [Date.parse('2023-3-16'), Date.parse('2023-3-17')]
    end
  end

  context 'POST /spaces/:id' do
    it 'adds the request to the requests table' do
      # Logs in as gary
      post('/login_attempt', { email: 'gary@email.com', password: 'garypassword' })

      response = post('/spaces/1', date: '2023-4-18')

      repo = RequestRepository.new

      expect(repo.all.last.id).to eq 8
      expect(repo.all.last.space_id).to eq 1
      expect(repo.all.last.requester_id).to eq 2
      expect(repo.all.last.date).to eq Date.parse('2023-4-18')
      expect(repo.all.last.status).to eq 'requested'
    end
  end

  context 'GET /about' do
    it "displays an About page" do
      response = get('/about')
      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>About Us</h1>')
      expect(response.body).to include('Destablising local housing markets in the most luxurious way possible since 2023')
    end
  end
end
