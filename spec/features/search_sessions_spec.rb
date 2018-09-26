# frozen_string_literal: true

describe App do
  before do
    DB[:sessions].truncate
    DB[:userdetails].truncate
  end

  describe 'GET /authentication/events/search' do
    context 'given no sessions for any user' do
      it 'can retrieve no events' do
        get '/authentication/events/search/aaaaaa'

        expect(JSON.parse(last_response.body)).to eq([])
      end
    end

    context 'given one session for a user' do
      before do
        Session.create(
          start: Time.now,
          username: 'VYKZDK',
          mac: '',
          ap: '',
          siteIP: '',
          building_identifier: ''
        )
      end

      it 'can retrieve the users event' do
        get '/authentication/events/search/VYKZDK'

        expect(JSON.parse(last_response.body)).to eq([{'username' => 'VYKZDK'}])
        expect(last_response.status).to eq(200)
      end
    end

    context 'given one session for two users' do
      before do
        Session.create(
          start: Time.now,
          username: 'VYKZDK',
          mac: '',
          ap: '',
          siteIP: '',
          building_identifier: ''
        )
        Session.create(
          start: Time.now,
          username: 'ZZZZZZ',
          mac: '',
          ap: '',
          siteIP: '',
          building_identifier: ''
        )
      end

      it 'can retrieve the correct users event' do
        get '/authentication/events/search/ZZZZZZ'

        expect(JSON.parse(last_response.body)).to eq([{'username' => 'ZZZZZZ'}])
        expect(last_response.status).to eq(200)
      end
    end
  end
end
