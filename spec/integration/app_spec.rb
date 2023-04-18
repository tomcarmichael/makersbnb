require "spec_helper"
require "rack/test"
require_relative '../../app'
require 'json'

describe Application do
  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods

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

end
