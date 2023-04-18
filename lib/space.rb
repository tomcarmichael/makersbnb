class Space
  attr_accessor :id, :name, :description, :price_per_night, :user_id, :available_dates

  def initialize()
    @available_dates = []
  end
end