# spaces Model and Repository Classes Design Recipe

## 1. Design and create the Table

If the table is already created in the database, you can skip this step.

Otherwise, [follow this recipe to design and create the SQL schema for your table](./single_table_design_recipe_template.md).

*In this template, we'll use an example table `Recipes`*

```
# EXAMPLE

Table: spaces

Columns:

id | name | description | price_per_night | owner_ID | available_dates
```

## 4. Implement the Model class

Define the attributes of your Model class. You can usually map the table columns to the attributes of the class, including primary and foreign keys.

```ruby
# EXAMPLE
# Table name: spaces

# Model class
# (in lib/space.rb)

class Space

  # Replace the attributes by your own columns.
  attr_accessor :id, :name, :description, :price_per_night, :owner_id, :available_dates
end
```

## 5. Define the Repository Class interface

Your Repository class will need to implement methods for each "read" or "write" operation you'd like to run against the database.

Using comments, define the method signatures (arguments and return value) and what they do - write up the SQL queries that will be used by each method.

```ruby
# EXAMPLE
# Table name: Spaces

# Repository class
# (in lib/space_repository.rb)

class SpaceRepository

  def all
    # SELECT * FROM spaces;

    # Returns an array of Space objects.
  end  

  def find_by_id(id) # One argument: the id (number)
    # SELECT * FROM spaces WHERE id = $1;

    # Returns a single Space object.
  end

  def create(space)
    # INSERT INTO spaces (name, description, price_per_night, owner_id, available_dates) VALUES = ($1, $2, $3, $4, $5);

    # Returns nil
  end
end
```

## 6. Write Test Examples

Write Ruby code that defines the expected behaviour of the Repository class, following your design from the table written in step 5.

These examples will later be encoded as RSpec tests.

```ruby
# Get all Spaces

repo = SpaceRepository.new

spaces = repo.all

spaces.length # =>  6

spaces[0].id # =>  1
spaces[0].name # =>  'Happy meadows'
spaces[0].description # =>  'A happy place'
spaces[0].price_per_night # =>  7.99

spaces.last.id # =>  2
spaces.last.name # =>  'Icy flower patch'
spaces.last.available_dates # => [2023-4-18, 2023-4-19, 2023-4-20, 2023-4-21]
spaces.last.owner_id # =>  4

# Get a single Space object by ID

repo = SpaceRepository.new

space = repo.find(3)

space.id # =>  3
space.name # =>  'Melancholy marsh'
space.price_per_night # =>  10.50
space.owner_id # =>  2
space.available_dates # => [2023-4-1, 2023-4-2, 2023-4-7]

# Create a new row in spaces

space = Space.new
space.name = "Bowser's Palace"
space.description = "Boss level"
space.owner_id = 4
space.price_per_night = 49.99
space.available_dates = [2023-5-4, 1994-7-9, 2023-7-10]

repo = SpaceRepository.new
repo.create(space)

all_spaces = repo.all

all_spaces.length # => 7
all_spaces.last.name # => "Bowser's Palace"
all_spaces.last.owner_id # => 4


```

Encode this example as a test.

## 7. Reload the SQL seeds before each test run

Running the SQL code present in the seed file will empty the table and re-insert the seed data.

This is so you get a fresh table contents every time you run the test suite.

```ruby
# EXAMPLE

# file: spec/space_repository_spec.rb

def reset_Recipes_table
  seed_sql = File.read('spec/seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'makersbnb-test' })
  connection.exec(seed_sql)
end

describe RecipeRepository do
  before(:each) do 
    reset_Recipes_table
  end

  # (your tests will go here).
end
```

## 8. Test-drive and implement the Repository class behaviour

_After each test you write, follow the test-driving process of red, green, refactor to implement the behaviour._

