require_relative './user'
require_relative './spaces_repository'
require_relative './space'

class UserRepository

  def all
    users = []
    sql = "SELECT id, name, username, email, password FROM users"
    
    result_set = DatabaseConnection.exec_params(sql, [])
    result_set.each do |record|
      user = User.new
      user.id = record['id']
      user.name = record['name']
      user.username = record['username']
      user.email = record['email']
      user.password = record['password']
      users << user
    end
    return users
  end

  def find_by_id(id)
    sql = "SELECT id, name, username, email, password FROM users WHERE id = $1"
    result_set = DatabaseConnection.exec_params(sql, [id])
    record = result_set[0]
    user = User.new
    user.id = record['id']
    user.name = record['name']
    user.username = record['username']
    user.email = record['email']
    user.password = record['password']

    return user
  end

  def find_by_id_with_spaces(id)
    sql = 'SELECT users.id AS user_id, users.name AS full_name, users.username, users.email, users.password, spaces.id AS space_id, spaces.name AS space_name, spaces.description, spaces.price_per_night, spaces.available_dates FROM users JOIN spaces ON spaces.owner_id = users.id WHERE users.id=$1'
    
   result_set = DatabaseConnection.exec_params(sql, [id])
    
    record = result_set[0]
    user = User.new
    user.id = record['user_id']
    user.name = record['full_name']
    user.username = record['username']
    user.email = record['email']
    user.password = record['password']

    user.spaces = []

    result_set.each do |record|
      space = Space.new
      space.id = record['space_id']
      space.name = record['space_name']
      space.description = record['description']
      space.price_per_night = record['price_per_night']
      space.available_dates = record['available_dates']

      user.spaces << space
    end
    return user
  end
  #     # left in as could possibly be useful with integration:
  # def all_with_spaces
  #   users_with_spaces = []
  #   sql = 'SELECT users.id AS user_id, users.name AS full_name, users.username, users.email, users.password, spaces.id AS space_id, spaces.name AS space_name, spaces.description, spaces.price_per_night, spaces.available_dates FROM users JOIN spaces ON spaces.owner_id = users.id'
  #   result_set = DatabaseConnection.exec_params(sql, [])
    
  #   result_set.each do |record|
  #     user = User.new
  #     space = Space.new
  #     user.id = record['user_id']
  #     user.name = record['full_name']
  #     user.username = record['username']
  #     user.email = record['email']
  #     user.password = record['password']
  #     user.spaces = []
  #     p record['space_name']
  #     p user
  #     users_with_spaces << user

  #     space.space_id = record['space_id']
  #     space.space_name record['space_name']
  #     space.description = record['description']
  #     space.price_per_night = record['price_per_night']
  #     space.available_dates = record['available_dates']
  #     users << user
  #   end
  #   return users_with_spaces
  # end
end