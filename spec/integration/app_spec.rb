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
    context "when the user is logged in" do
      it "redirects to '/'" do
        # TODO
      end
    end
    context "when the user isn't logged in" do
      it "displays a login form" do
        response = get('/login')
        expect(response.status).to eq 200
        expect(response.body).to include('<form method="POST" action="/login_attempt">')
        expect(response.body).to include('<label for="email">Email Address:</label>')
        expect(response.body).to include('<input type="text" name="email" />')
        expect(response.body).to include('<label for="password">Password:</label>')
        expect(response.body).to include('<input type="password" name="password" />')
      end
    end
  end

end
