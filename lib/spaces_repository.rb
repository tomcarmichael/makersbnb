require_relative "./database_connection"
require_relative "./space"

class SpacesRepository
  def all
    sql = 'SELECT * FROM spaces;'
    result_set = DatabaseConnection.exec_params(sql, [])

    return result_set.map(&method(:convert_to_space))
  end

  def find_by_id(id) # One argument: the id (number)
    sql = 'SELECT * FROM spaces WHERE id = $1;'
    result = DatabaseConnection.exec_params(sql, [id]).first

    return convert_to_space(result)
  end

  def create(space)
    sql = 'INSERT INTO spaces (name, description, price_per_night, owner_id, available_dates)
          VALUES ($1, $2, $3, $4, $5);'

    params = [space.name, space.description, space.price_per_night, space.owner_id, 
              convert_date_objects_to_string(space.available_dates)]

    DatabaseConnection.exec_params(sql, params)
    return nil
  end

  def convert_to_space(record)
    space = Space.new
    space.id = record['id'].to_i
    space.name = record['name']
    space.description = record['description']
    space.price_per_night = record['price_per_night'].to_f.round(2)
    space.owner_id = record['owner_id'].to_i
    space.available_dates = convert_to_date_objects(record['available_dates'])

    return space
  end

  def convert_to_date_objects(dates_string)
    # SQL query of the "available_dates" col returns a single string formatted as: "{YYYY-MM-DD,YYY-MM-DD}"
    date_array = dates_string[1..-2].split(',')

    return date_array.map { |date| Date.parse(date) }
  end

  def convert_date_objects_to_string(dates_array)
    available_dates_string = dates_array.map { |date| date.to_s }.join(',')
    available_dates_string.prepend('{').concat('}')
  end
end
