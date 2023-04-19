class Helper
  def self.record_to_request(record)
    request = Request.new
    request.id = record['id'].to_i
    request.space_id = record['space_id'].to_i
    request.requester_id = record['requester_id'].to_i
    request.date = Date.parse(record['date'])
    request.status = record['status']
    return request
  end

end

