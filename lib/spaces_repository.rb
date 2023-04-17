require_relative "./database_connection"
require_relative "./space"

class SpacesRepository
  def all
    sql = 'SELECT * FROM spaces;'
    result_set = DatabaseConnection.exec_params(sql, [])

    spaces = []

    result_set.each do |row|
      space = Space.new
      space.id = row['id'].to_i
      space.name = row['name']
      space.description = row['description']
      space.price_per_night = row['price_per_night'].to_f.round(2)
      space.owner_id = row['owner_id'].to_i
      space.available_dates = convert_to_date_objects(row['available_dates'])
      spaces << space
    end

    return spaces
  end

  def find_by_id(id) # One argument: the id (number)
    sql = 'SELECT * FROM spaces WHERE id = $1;'
    result_set = DatabaseConnection.exec_params(sql, [id]).first

    space = Space.new
    space.id = result_set['id'].to_i
    space.name = result_set['name']
    space.description = result_set['description']
    space.price_per_night = result_set['price_per_night'].to_f.round(2)
    space.owner_id = result_set['owner_id'].to_i
    space.available_dates = convert_to_date_objects(result_set['available_dates'])

    return space
  end

  def create(space)
    sql = 'INSERT INTO spaces (name, description, price_per_night, owner_id, available_dates)
          VALUES ($1, $2, $3, $4, $5);'
    params = [space.name, space.description, space.price_per_night, space.owner_id, space.available_dates]

    DatabaseConnection.exec_params(sql, params)

    return nil
  end

  def convert_to_date_objects(dates_string)
    # SQL query of the "available_dates" col returns a single string formatted as: "{YYYY-MM-DD,YYY-MM-DD}"
    date_array = dates_string[1..-2].split(',')
    return date_array.map do |date|
      Date.parse(date)
    end
  end
end
