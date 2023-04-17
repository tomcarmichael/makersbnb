require "spaces_repository"

def reset_Recipes_table
  seed_sql = File.read('spec/seeds/seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'makersbnb_test' })
  connection.exec(seed_sql)
end

describe SpacesRepository do
  before(:each) do 
    reset_Recipes_table
  end

  let(:repo) { SpacesRepository.new }

  xit "returns all spaces" do
    spaces = repo.all
    expect(spaces.length).to eq(6)
    expect(spaces[0].id).to eq(1)
    expect(spaces[0].name).to eq('Happy meadows')
    expect(spaces[0].description).to eq 'A happy place'
    expect(spaces[0].price_per_night).to eq 10.50
    expect(spaces.last.id).to eq 2
    expect(spaces.last.name ).to eq 'Icy flower patch'
    expected_dates = ['2023-4-18', '2023-4-19', '2023-4-20', '2023-4-21']
    expect(spaces.last.available_dates).to eq (expected_dates.map { |date| Date.parse(date) })

    expect(spaces.last.owner_id).to eq 4
  end


  it "finds a single space by ID" do
    space = repo.find_by_id(3)
    expect(space.id).to eq 3
    expect(space.name).to eq 'Melancholy marsh'
    expect(space.price_per_night).to eq 10.50
    expect(space.owner_id).to eq 2
    expected_dates = ['2023-4-1', '2023-4-2', '2023-4-7']
    expect(space.available_dates).to eq (expected_dates.map { |date| Date.parse(date) })
  end


  xit "inserts a new Space into the DB" do
    space = Space.new
    space.name = "Bowser's Palace"
    space.description = "Boss level"
    space.owner_id = 4
    space.price_per_night = 49.99
    space.available_dates = ['2023-5-4', '1994-7-9', '2023-7-10']

    repo.create(space)
    all_spaces = repo.all

    expect(all_spaces.length).to eq 7
    expect(all_spaces.last.name).to eq "Bowser's Palace"
    expect(all_spaces.last.owner_id).to eq 4
  end
end