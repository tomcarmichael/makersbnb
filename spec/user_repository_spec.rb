require "user_repository"

def reset_users_table
  seed_sql = File.read('spec/seeds/seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'makersbnb_test' })
  connection.exec(seed_sql)
end

describe UserRepository do
  before(:each) do 
    reset_users_table
  end

  it "return all users" do

    repo = UserRepository.new

    users = repo.all

    expect(users.length).to eq 5

    expect(users[0].id).to eq '1'
    expect(users[0].name).to eq 'Sam'
    expect(users[0].username).to eq 'usersam'
    expect(users[0].email).to eq 'sam@email.com'
    expect(users[0].password).to eq 'sampassword'


    expect(users[1].id).to eq '2'
    expect(users[1].name).to eq 'Gary'
    expect(users[1].username).to eq 'usergary'
    expect(users[1].email).to eq 'gary@email.com'
    expect(users[1].password).to eq 'garypassword'

  end

  it "finds the correct user by id" do

    repo = UserRepository.new

    user = repo.find_by_id(1)

    expect(user.id).to eq '1'
    expect(user.name).to eq 'Sam'
    expect(user.username).to eq 'usersam'
    expect(user.email).to eq 'sam@email.com'
    expect(user.password).to eq 'sampassword'
  end

  it "returns a user and their spaces" do
    repo = UserRepository.new
    user = repo.find_by_id_with_spaces(2)
    fake_space_1 = double(:fake_space, name: "Scary fields", description: 'A scary field', price_per_night: 11.99, available_dates: ['2023-3-16', '2023-3-17', '2023-3-18'], user_id: 2)
    fake_space_2 = double(:fake_space, name: "Melancholy marsh", description: 'A place to reflect', price_per_night: 10.50, available_dates: ['2023-4-01, 2023-4-02, 2023-04-07'], user_id: 2)
    user.spaces = [fake_space_1,fake_space_2]

    expect(user.name).to eq "Gary"
    expect(user.spaces.first.name).to eq 'Scary fields'
  end
end