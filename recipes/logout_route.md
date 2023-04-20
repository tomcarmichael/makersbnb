# POST /logout Route Design Recipe

## 1. Design the Route Signature

You'll need to include:
  * the HTTP method
  * the path
  * any query parameters (passed in the URL)
  * or body parameters (passed in the request body)

  Gets a list of spaces, ordered by most recent. 
  Method: POST  
  Path: /logout
  Parameters: none

## 2. Design the Response

The route might return different responses, depending on the result.

For example, a route for a specific blog post (by its ID) might return `200 OK` if the post exists, but `404 Not Found` if the post is not found in the database.

Your response might return plain text, JSON, or HTML code. 

_Replace the below with your own design. Think of all the different possible responses your route will return._

```
<!-- Response: 302  -->

redirect '/'
```

## 3. Write Examples

_Replace these with your own design._

```
# Request:

# Expected response:

Response for 302
```

## 4. Encode as Tests Examples

```ruby
# EXAMPLE
# file: spec/integration/application_spec.rb

require "spec_helper"

describe Application do
  include Rack::Test::Methods

  let(:app) { Application.new }
  let(:session_params) { { 'rack.session' => { user: double(:user_object) } } }


  context "layout" do
    it "displays a logout options via POST when user is logged in" do
      response = get('/spaces', {}, session_params)
      expect(response.body).to include('<form method="post" action="/logout" class="inline">
              <button type="submit" name="logout" class="link-button">Log out</button>
            </form>')
    end
  end

  context "POST /logout" do
    it 'redirects to home page' do
      response = post("/logout")
      expect(response.status).to eq(302)
      follow_redirect!
      expect(last_request.path).to eq('/')
    end
  end
   
  it "logs the user out from session object" do
    response = post('/logout', {}, session_params)
    expect(response.status).to eq(302)
    follow_redirect!
    expect(last_request.env['rack.session'][:user]).to be_nil
  end
end
```

## 5. Implement the Route

Write the route and web server code to implement the route behaviour.