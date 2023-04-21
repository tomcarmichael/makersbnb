require_relative './database_connection'
require_relative './space'

class SpacesRepository
  def all
    sql = 'SELECT * FROM spaces;'
    result_set = DatabaseConnection.exec_params(sql, [])

    result_set.map(&Helper.method(:convert_to_space))
  end

  def find_by_id(id) # One argument: the id (number)
    sql = 'SELECT * FROM spaces WHERE id = $1;'
    result = DatabaseConnection.exec_params(sql, [id]).first

    Helper.convert_to_space(result)
  end

  def create(space)
    sql = 'INSERT INTO spaces (name, description, price_per_night, owner_id, available_dates)
          VALUES ($1, $2, $3, $4, $5);'

    params = [space.name, space.description, space.price_per_night, space.owner_id,
              Helper.convert_date_objects_to_string(space.available_dates)]

    DatabaseConnection.exec_params(sql, params)
    nil
  end
end
