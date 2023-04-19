# {{ METHOD }} {{ PATH}} Route Design Recipe

_Copy this design recipe template to test-drive a Sinatra route._

## 1. Design the Route Signature

You'll need to include:
  * the HTTP method get
  * the path /spaces/:id
  * any query parameters (passed in the URL)
  * or body parameters (passed in the request body)

## 2. Design the Response

The route might return different responses, depending on the result.

For example, a route for a specific blog post (by its ID) might return `200 OK` if the post exists, but `404 Not Found` if the post is not found in the database.

Your response might return plain text, JSON, or HTML code. 

_Replace the below with your own design. Think of all the different possible responses your route will return._

```html
<!-- EXAMPLE -->
<!-- Response when the post is found: 200 OK -->

<html>
  <head></head>
  <body>
    <h1>name</h1>
    <div>description</div>
  </body>
</html>
```

```html
<!-- EXAMPLE -->
<!-- Response when the post is not found: 404 Not Found -->
 find_by_id.nil
redirect /
```

## 3. Write Examples

_Replace these with your own design._

```
# Request:

GET /spaces/2

# Expected response:

expect(response.status).to eq 200
expect(response.body).to include("<h1>Scary fields</h1>") 
expect(response.body).to include("A scary field") 
expect(response.body).to include('<label for="date">Select a date:</label>')
expect(response.body).to include('<select name="date">') 
expect(response.body).to include('<option value="2023-03-16">2023-03-16</option>')
expect(response.body).to include('<option value="2023-03-17">2023-03-17</option>')
expect(response.body).to include('<option value="2023-03-18">2023-03-18</option>')


GET /spaces/300

expect(response.status).to eq 302
follow_redirect!
expect(last_request.path).to eq('/spaces')

```

## 4. Encode as Tests Examples
