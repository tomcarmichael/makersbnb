require 'user_repository'

def reset_users_table
  seed_sql = File.read('spec/seeds/seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'makersbnb_test' })
  connection.exec(seed_sql)
end

describe UserRepository do
  before(:each) do
    reset_users_table
  end

  it 'return all users' do
    repo = UserRepository.new

    users = repo.all

    expect(users.length).to eq 5

    expect(users[0].id).to eq 1
    expect(users[0].name).to eq 'Sam'
    expect(users[0].username).to eq 'usersam'
    expect(users[0].email).to eq 'sam@email.com'
    expect(users[0].password).to eq 'sampassword'

    expect(users[1].id).to eq 2
    expect(users[1].name).to eq 'Gary'
    expect(users[1].username).to eq 'usergary'
    expect(users[1].email).to eq 'gary@email.com'
    expect(users[1].password).to eq 'garypassword'
  end

  it 'finds the correct user by id' do
    repo = UserRepository.new

    user = repo.find_by_id(1)

    expect(user.id).to eq 1
    expect(user.name).to eq 'Sam'
    expect(user.username).to eq 'usersam'
    expect(user.email).to eq 'sam@email.com'
    expect(user.password).to eq 'sampassword'
  end

  it 'returns a user and their spaces' do
    repo = UserRepository.new
    user = repo.find_by_id_with_spaces(2)
    # fake_space_1 = double(:fake_space, space_name: "Scary fields", description: 'A scary field', price_per_night: 11.99, available_dates: ['2023-3-16', '2023-3-17', '2023-3-18'], user_id: 2)
    # fake_space_2 = double(:fake_space, space_name: "Melancholy marsh", description: 'A place to reflect', price_per_night: 10.50, available_dates: ['2023-4-01, 2023-4-02, 2023-04-07'], user_id: 2)
    # user.spaces = [fake_space_1,fake_space_2]

    expect(user.name).to eq 'Gary'
    expect(user.spaces.first.name).to eq 'Scary fields'
  end

  context '#find_by_email'
  it 'finds a user by email' do
    repo = UserRepository.new

    user = repo.find_by_email('tom@email.com')

    expect(user.id).to eq 4
    expect(user.name).to eq 'Tom'
    expect(user.username).to eq 'usertom'
    expect(user.email).to eq 'tom@email.com'
    expect(user.password).to eq 'tompassword'
  end

  it 'returns nil if given invalid email' do
    repo = UserRepository.new

    user = repo.find_by_email('faker@example.com')

    expect(user).to eq nil
  end

  # xit 'returns all users and their spaces' do
  #   repo = UserRepository.new
  #   users = repo.all_with_spaces
  #   fake_space_1 = double(:fake_space, space_name: "Scary fields", description: 'A scary field', price_per_night: 11.99, available_dates: ['2023-3-16', '2023-3-17', '2023-3-18'], user_id: 2)
  #   fake_space_2 = double(:fake_space, space_name: "Melancholy marsh", description: 'A place to reflect', price_per_night: 10.50, available_dates: ['2023-4-01, 2023-4-02, 2023-04-07'], user_id: 2)
  #   fake_space_3 = double(:fake_space, space_name: "Melancholy hill", description: 'A place with a plastic tree', price_per_night: 16.50, available_dates: ['2023-4-28, 2023-4-29, 2023-04-30'], user_id: 1)

  #   users[0].spaces = [fake_space_1]
  #   users[1].spaces = [fake_space_2]
  #   users[1].spaces = [fake_space_3]

  #   expect(users.length).to eq 5
  #   expect(users[0].spaces.name).to eq "Melancholy hill"
  #   expect(users[1].spaces[0].space_name).to eq "Scary fields"
  #   expect(users[1].spaces[1].space_name).to eq "Melancholy marsh"

  # end
end
