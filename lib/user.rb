class User
  attr_accessor :id, :name, :username, :email, :password, :spaces

  def initialize()
    @spaces = []
  end
end