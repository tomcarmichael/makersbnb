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

  let(:repo) {RequestRepository.new}

  context '#all' do
    it "returns a list of all requests" do
      requests = repo.all

      expect(requests.first.id).to eq 1
      expect(requests.first.space_id).to eq 1
      expect(requests.first.requester_id).to eq 2
      expect(requests.first.date).to eq Date.parse('2023-4-17')
      expect(requests.first.status).to eq 'requested'
      
      expect(requests.last.id).to eq 7
      expect(requests.last.space_id).to eq 1
      expect(requests.last.requester_id).to eq 3
      expect(requests.last.date).to eq Date.parse('2023-4-18')
      expect(requests.last.status).to eq 'rejected'
    end
  end

  context '#create' do
    it "creates a request" do
      request = Request.new
      request.space_id = 2   
      request.requester_id = 2   
      request.date = Date.parse('2023-10-17')
      
      repo.create(request)

      expect(repo.all.last.id).to eq 8
      expect(repo.all.last.space_id).to eq 2
      expect(repo.all.last.requester_id).to eq 2
      expect(repo.all.last.date).to eq Date.parse('2023-10-17')
    end
  end

  context '#delete' do
    it "deletes a request" do
      repo.delete(1)

      requests = repo.all
      
      expect(requests.first.id).to eq 2
      expect(requests.first.space_id).to eq 1
      expect(requests.first.requester_id).to eq 3
      expect(requests.first.date).to eq Date.parse('2023-4-17')
    end
  end

  context '#find_by_requester_id' do
    it "finds all requests with associated requester id" do
      requests = repo.find_by_requester_id(3)

      expect(requests.length).to eq 3
      expect(requests.first.id).to eq 2
      expect(requests.first.space_id).to eq 1
      expect(requests.first.requester_id).to eq 3
      expect(requests.first.date).to eq Date.parse('2023-4-17')
    end
  end

  context '#find_by_space_id' do
    it "finds all requests with associated space id" do
      requests = repo.find_by_space_id(1)

      expect(requests.length).to eq 4
      expect(requests.first.id).to eq 1
      expect(requests.first.space_id).to eq 1
      expect(requests.first.requester_id).to eq 2
      expect(requests.first.date).to eq Date.parse('2023-4-17')
    end
  end

  context '#find_by_id' do
    it "finds a request by id" do
      request = repo.find_by_id(1)

      expect(request.id).to eq 1
      expect(request.space_id).to eq 1
      expect(request.requester_id).to eq 2
      expect(request.date).to eq Date.parse('2023-4-17')
    end
  end

  context '#find_by_place_id_and_date' do
    it "finds a request by place id and date" do
      requests = repo.find_by_place_id_and_date(1, '2023-4-17')

      expect(requests.first.id).to eq 1
      expect(requests.first.space_id).to eq 1
      expect(requests.first.requester_id).to eq 2
      expect(requests.first.date).to eq Date.parse('2023-4-17')
    end
  end
end