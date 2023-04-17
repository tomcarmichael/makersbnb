require_relative './user'

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
    sql = 'SELECT user.id AS user_id, user.name AS user_name, user.username, user.email, user.password, spaces.id AS space_id, spaces.name AS space_name, spaces.description, spaces.price_per_night, spaces.available_dates FROM users JOIN spaces ON spaces.owner_id = users.id WHERE users.id=$1'
    
    result_set = DatabaseConnection.exec_params(sql, [id])
    
    record = result_set[0]
    user = User.new
    user.id = record['user_id']
    user.name = record['name']
    user.username = record['username']
    user.email = record['email']
    user.password = record['password']

    user.spaces = []
    return user
    # Executes the SQL query:
    # SELECT id, name, cohort_name FROM students WHERE id = $1;

    # Returns a single Student object.
  end

  def all_with_spaces
  end

  # Add more methods below for each operation you'd like to implement.

  # def create(student)
  # end

  # def update(student)
  # end

  # def delete(student)
  # end
end