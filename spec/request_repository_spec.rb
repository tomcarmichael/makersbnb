require_relative '../lib/request'
require_relative '../lib/request_repository'

def reset_tables
  sql = File.read('spec/seeds/seeds.sql')
  connection = PG.connect({host: '127.0.0.1', dbname: 'makersbnb_test'})
  connection.exec(sql)
end


RSpec.describe RequestRepository do
  before(:each) do
    reset_tables
  end

  context '#all' do
    it "returns a list of all requests" do
      repo = RequestRepository.new

      requests = repo.all

      expect(requests.first.id).to eq 1
      expect(requests.first.space_id).to eq 1
      expect(requests.first.requester_id).to eq 2
      expect(requests.first.date).to eq '2023-4-17'
      
      expect(requests.last.id).to eq 5
      expect(requests.last.space_id).to eq 5
      expect(requests.last.requester_id).to eq 1
      expect(requests.last.date).to eq '2023-4-18'
    end
  end
end