require_relative './request'

class RequestRepository
  def all
    sql = 'SELECT * FROM requests'
    result_set = DatabaseConnection.exec_params(sql, [])
    
    return result_set.map(&method(:record_to_request))
  end

  def record_to_request(record)
    request = Request.new
    request.id = record['id'].to_i
    request.space_id = record['space_id'].to_i
    request.requester_id = record['requester_id'].to_i
    request.date = Date.parse(record['date'])
    return request
  end
end