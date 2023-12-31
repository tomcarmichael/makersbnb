require_relative '../lib/request'
require_relative '../lib/request_repository'

def reset_tables
  sql = File.read('spec/seeds/seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'makersbnb_test' })
  connection.exec(sql)
end

RSpec.describe RequestRepository do
  before(:each) do
    reset_tables
  end

  let(:repo) { RequestRepository.new }

  context '#all' do
    it 'returns a list of all requests' do
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
    it 'creates a request' do
      request = Request.new
      request.space_id = 2
      request.requester_id = 2
      request.date = Date.parse('2023-10-17')
      request.status = 'requested'

      repo.create(request)

      expect(repo.all.last.id).to eq 8
      expect(repo.all.last.space_id).to eq 2
      expect(repo.all.last.requester_id).to eq 2
      expect(repo.all.last.date).to eq Date.parse('2023-10-17')
      expect(repo.all.last.status).to eq 'requested'
    end
  end

  context '#delete' do
    it 'deletes a request' do
      repo.delete(1)

      requests = repo.all

      expect(requests.first.id).to eq 2
      expect(requests.first.space_id).to eq 1
      expect(requests.first.requester_id).to eq 3
      expect(requests.first.date).to eq Date.parse('2023-4-17')
    end
  end

  context '#find_by_requester_id' do
    it 'finds all requests with associated requester id' do
      requests = repo.find_by_requester_id(3)

      expect(requests.length).to eq 3
      expect(requests.first.id).to eq 2
      expect(requests.first.space_id).to eq 1
      expect(requests.first.requester_id).to eq 3
      expect(requests.first.date).to eq Date.parse('2023-4-17')
    end
  end

  context '#find_by_space_id' do
    it 'finds all requests with associated space id' do
      requests = repo.find_by_space_id(1)

      expect(requests.length).to eq 4
      expect(requests.first.id).to eq 1
      expect(requests.first.space_id).to eq 1
      expect(requests.first.requester_id).to eq 2
      expect(requests.first.date).to eq Date.parse('2023-4-17')
    end
  end

  context '#find_by_id' do
    it 'finds a request by id' do
      request = repo.find_by_id(1)

      expect(request.id).to eq 1
      expect(request.space_id).to eq 1
      expect(request.requester_id).to eq 2
      expect(request.date).to eq Date.parse('2023-4-17')
    end
  end

  context '#find_by_place_id_and_date' do
    it 'finds a request by place id and date' do
      requests = repo.find_by_place_id_and_date(1, '2023-4-17')

      expect(requests.first.id).to eq 1
      expect(requests.first.space_id).to eq 1
      expect(requests.first.requester_id).to eq 2
      expect(requests.first.date).to eq Date.parse('2023-4-17')
    end
  end

  context '#find_requests_for_user' do
    it 'finds all requests that pertain to a user id' do
      requests = repo.find_requests_for_user(2)

      expect(requests.first.space_id).to eq 2
      expect(requests.first.date).to eq Date.parse('2023-3-18')
      expect(requests.last.space_id).to eq 3
      expect(requests.last.date).to eq Date.parse('2023-4-1')
    end
  end

  context '#find_request_info_by_id' do
    it 'finds correct data pertaining to a request id' do
      request = repo.find_request_info_by_id(2)
      expect(request[:name]).to eq('Happy meadows')
      expect(request[:description]).to eq('A happy place')
      expect(request[:email]).to eq('jack@email.com')
      expect(request[:date]).to eq(Date.parse('2023-4-17'))
    end

    it 'returns the owner_id of the space that was requested' do
      request = repo.find_request_info_by_id(2)
      expect(request[:owner_id]).to eq 1
      request = repo.find_request_info_by_id(4)
      expect(request[:owner_id]).to eq 2
    end

    it 'returns the request_id of the space that was requested' do
      request = repo.find_request_info_by_id(2)
      expect(request[:request_id]).to eq 2
      request = repo.find_request_info_by_id(4)
      expect(request[:request_id]).to eq 4
    end

    it 'return the status of the request id' do
      request = repo.find_request_info_by_id(2)
      expect(request[:status]).to eq('requested')

      request = repo.find_request_info_by_id(6)
      expect(request[:status]).to eq('confirmed')

      request = repo.find_request_info_by_id(7)
      expect(request[:status]).to eq('rejected')
    end
  end

  context '#reject_request' do
    it "Updates request status to 'rejected' by ID & returns nil" do
      request_id = 4
      request_before_reject = repo.find_by_id(request_id)
      expect(request_before_reject.status).to eq 'requested'

      repo.reject_request(request_id)

      updated_request = repo.find_by_id(request_id)
      expect(updated_request.status).to eq 'rejected'
    end

    it 'returns nil' do
      expect(repo.reject_request(4)).to eq nil
    end
  end

  context '#accept_request' do
    it "Updates request status to 'accepted' by ID & returns nil" do
      request_id = 4
      request_before_accepted = repo.find_by_id(request_id)
      expect(request_before_accepted.status).to eq 'requested'

      repo.accept_request(request_id)

      updated_request = repo.find_by_id(request_id)
      expect(updated_request.status).to eq 'confirmed'
    end

    it 'returns nil' do
      expect(repo.accept_request(4)).to eq nil
    end

    it "rejects other requests for this date and space" do
      conflicting_request_1 = Request.new
      conflicting_request_1.space_id = 2
      conflicting_request_1.requester_id = 1
      conflicting_request_1.date = Date.parse('2023-3-18')
      conflicting_request_1.status = 'requested'
      
      conflicting_request_2 = Request.new
      conflicting_request_2.space_id = 2
      conflicting_request_2.requester_id = 4
      conflicting_request_2.date = Date.parse('2023-3-18')
      conflicting_request_2.status = 'requested'

      repo.create(conflicting_request_1)
      repo.create(conflicting_request_2)

      repo.accept_request(3)

      expect(repo.find_by_id(8).status).to eq 'rejected'
      expect(repo.find_by_id(9).status).to eq 'rejected'
    end
  end

  context '#find_conflicting_requests' do
    it 'returns a list of other request_ids that point towards the same space and date' do
      conflicting_request_1 = Request.new
      conflicting_request_1.space_id = 2
      conflicting_request_1.requester_id = 1
      conflicting_request_1.date = Date.parse('2023-3-18')
      conflicting_request_1.status = 'requested'
      
      conflicting_request_2 = Request.new
      conflicting_request_2.space_id = 2
      conflicting_request_2.requester_id = 4
      conflicting_request_2.date = Date.parse('2023-3-18')
      conflicting_request_2.status = 'requested'

      repo.create(conflicting_request_1)
      repo.create(conflicting_request_2)

      expect(repo.find_conflicting_requests(3)).to eq [8,9]
      expect(repo.find_conflicting_requests(8)).to eq [3,9]
      expect(repo.find_conflicting_requests(9)).to eq [3,8]
    end
  end
end
