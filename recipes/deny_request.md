Test drive a deny request button on the single_request view

POST ‘/deny_request’ 
params = request_id

Update requests table by request ID - set status column to “rejected”

Create method in request_repository reject_request(request_id)

Redirect (‘/requests’)

Update requests route in app.rb so it doesn’t display rejected requests