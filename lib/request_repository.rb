require_relative './request'

class RequestRepository
  def all
    sql = 'SELECT * FROM requests'
    result_set = DatabaseConnection.exec_params(sql, [])

    return result_set.map(&Helper.method(:record_to_request))
  end

  def create(request)
    sql = 'INSERT INTO requests (space_id, requester_id, date, status) VALUES ($1, $2, $3, $4)'
    params = [request.space_id, request.requester_id, request.date, request.status]

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

  def find_by_id(id)
    sql = 'SELECT * FROM requests WHERE id=$1'
    params = [id]

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

  def find_request_info_by_id(request_id)
    # sql = 'SELECT users.email, requests.date, spaces.name, spaces.description FROM requests JOIN spaces ON requests.space_id = spaces.id JOIN users ON requests.requester_id = users.id WHERE requests.id = $1;
    # '
    sql = 'SELECT users.email, requests.id AS "request_id", requests.date, spaces.name, spaces.description, spaces.owner_id, requests.status
            FROM requests JOIN spaces ON requests.space_id = spaces.id
              JOIN users ON requests.requester_id = users.id
                WHERE requests.id = $1;'
    params = [request_id]

    result_set = DatabaseConnection.exec_params(sql, params).first

    request_data = {}
    request_data[:name] = result_set['name']
    request_data[:description] = result_set['description']
    request_data[:email] = result_set['email']
    request_data[:date] = Date.parse(result_set['date'])
    request_data[:owner_id] = result_set['owner_id'].to_i
    request_data[:request_id] = result_set['request_id'].to_i
    request_data[:status] = result_set['status']

    return request_data
  end

  def reject_request(request_id)
    sql = "UPDATE requests SET status = 'rejected' WHERE id = $1;"
    DatabaseConnection.exec_params(sql, [request_id])

    return nil
  end

  def accept_request(request_id)
    sql = "UPDATE requests SET status = 'confirmed' WHERE id = $1;"
    DatabaseConnection.exec_params(sql, [request_id])
    conflicting_requests = find_conflicting_requests(request_id)
    unless conflicting_requests.empty?
      # sql = "UPDATE requests SET status = 'rejected' WHERE id IN ($1)"
      # DatabaseConnection.exec_params(sql, [conflicting_requests])
      conflicting_requests.each do |id|
        reject_request(id)
      end
    end

    # Update the available dates
    request = find_by_id(request_id)
    space = SpacesRepository.new.find_by_id(request.space_id)
    space.available_dates.delete(request.date)

    SpacesRepository.new.update(space)

    return nil
  end

  def find_conflicting_requests(request_id)
    request = find_by_id(request_id)
    sql = 'SELECT id FROM requests WHERE space_id = $1 AND date = $2 AND id != $3'
    params = [request.space_id, request.date, request.id]

    result_set = DatabaseConnection.exec_params(sql, params)

    return result_set.map do |record|
      record['id'].to_i
    end
  end
end
