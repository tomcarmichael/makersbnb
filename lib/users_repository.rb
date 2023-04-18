require_relative './user'
require_relative './spaces_repository'
require_relative './space'

class UserRepository

  def find_by_email(email)
    sql = 'SELECT * FROM users WHERE email = $1;'
    params = [email]
    result = DatabaseConnection.exec_params(sql, params).first

    user = User.new
    user.id = result['id'].to_i
    user.name = result['name']
    user.username = result['username']
    user.email = result['email']
    user.password = result['password']
    return user
    # return # method call for converting to User object
  end
end