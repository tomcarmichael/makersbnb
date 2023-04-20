require_relative './request'
require_relative './helpers'

class RequestRepository
  def all
    sql = 'SELECT * FROM requests'
    result_set = DatabaseConnection.exec_params(sql, [])
    
    return result_set.map(&Helper.method(:record_to_request))
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
    return result_set.map(&Helper.method(:record_to_request))
  end

  def find_by_space_id(space_id)
    sql = 'SELECT * FROM requests WHERE space_id=$1'
    params = [space_id]

    result_set = DatabaseConnection.exec_params(sql, params)
    return result_set.map(&Helper.method(:record_to_request))
  end

  def find_by_id(space_id)
    sql = 'SELECT * FROM requests WHERE id=$1'
    params = [space_id]

    result_set = DatabaseConnection.exec_params(sql, params)
    return Helper.record_to_request(result_set.first)
  end

  def find_by_place_id_and_date(space_id, date)
    sql = 'SELECT * FROM requests WHERE space_id=$1 AND date=$2'
    params = [space_id, date]

    result_set = DatabaseConnection.exec_params(sql, params)
    return result_set.map(&Helper.method(:record_to_request))
  end

  def find_requests_for_user(user_id) 
    sql = 'SELECT requests.id, requests.space_id, requests.requester_id, requests.date, requests.status, spaces.owner_id FROM requests JOIN spaces ON requests.space_id = spaces.id WHERE spaces.owner_id = $1'
    params = [user_id]

    result_set = DatabaseConnection.exec_params(sql, params)
    return result_set.map(&Helper.method(:record_to_request))
  end
  
  
end