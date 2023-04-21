class Helper
  def self.record_to_request(record)
    return nil unless record

    request = Request.new
    request.id = record['id'].to_i
    request.space_id = record['space_id'].to_i
    request.requester_id = record['requester_id'].to_i
    request.date = Date.parse(record['date'])
    request.status = record['status']
    return request
  end

  def self.convert_to_date_objects(dates_string)
    # SQL query of the "available_dates" col returns a single string formatted as: "{YYYY-MM-DD,YYY-MM-DD}"
    date_array = dates_string[1..-2].split(',')

    return date_array.map { |date| Date.parse(date) }
  end

  def self.convert_date_objects_to_string(dates_array)
    available_dates_string = dates_array.map { |date| date.to_s }.join(',')
    available_dates_string.prepend('{').concat('}')
  end

  def self.convert_to_space(record)
    return nil unless record

    space = Space.new
    space.id = record['id'].to_i
    space.name = record['name']
    space.description = record['description']
    space.price_per_night = record['price_per_night'].to_f.round(2)
    space.owner_id = record['owner_id'].to_i
    space.available_dates = Helper.convert_to_date_objects(record['available_dates'])

    return space
  end

  def self.convert_to_user(record)
    return nil unless record

    user = User.new
    user.id = record['id'].to_i
    user.name = record['name']
    user.username = record['username']
    user.email = record['email']
    user.password = record['password']

    return user
  end

  def self.current_page?(path = '')
    request.path_info == '/' + path
  end
end
