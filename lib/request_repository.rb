require_relative './request'

class RequestRepository
  def all
    sql = 'SELECT * FROM requests'
    result_set = DatabaseConnection.exec_params(sql, [])
    
    return result_set.map(&method(:record_to_request))
  end

  def create(request)
    sql = 'INSERT INTO requests (space_id, requester_id, date) VALUES ($1, $2, $3)'
    params = [request.space_id, request.requester_id, request.date]

    DatabaseConnection.exec_params(sql, params)
    return nil
  end

  def delete(request_id)
    sql = 'DELETE FROM requests WHERE id=$1'
    params = [request_id]

    DatabaseConnection.exec_params(sql, params)
    return nil
  end

  def find_by_requester_id(requester_id)
    sql = 'SELECT * FROM requests WHERE requester_id=$1'
    params = [requester_id]

    result_set = DatabaseConnection.exec_params(sql, params)
    return result_set.map(&method(:record_to_request))
  end

  def find_by_space_id(space_id)
    sql = 'SELECT * FROM requests WHERE space_id=$1'
    params = [space_id]

    result_set = DatabaseConnection.exec_params(sql, params)
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