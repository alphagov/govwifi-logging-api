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

        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)).to eq([])
      end
    end

    context 'given one session for a user' do
      before do
        Session.create(
          start: "2018-10-01 18:18:09 +0000",
          username: 'VYKZDK',
          mac: '',
          ap: '',
          siteIP: '',
          building_identifier: ''
        )
      end

      it 'can retrieve the users event' do
        get '/authentication/events/search/VYKZDK'

        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)).to eq(
          [
            {
              "ap" => "",
              "building_identifier" => "",
              "id" => 1,
              "mac" => "",
              "siteIP" => "",
              "start" => "2018-10-01 18:18:09 +0000",
              "stop" => nil,
              "username" => "VYKZDK"
            }
          ]
        )
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

        expect(last_response.status).to eq(200)
        json_response = JSON.parse(last_response.body)
        expect(json_response.length).to eq(1)
        expect(json_response.first['username']).to eq('ZZZZZZ')
      end
    end

    context 'given more than one hundred sessions for a user' do
      before do
        100.times do
          Session.create(
            start: "2018-01-01 00:00:01 +0000",
            username: 'VYKZDK',
            mac: '',
            ap: '',
            siteIP: '',
            building_identifier: ''
          )
        end

        2.times do
          Session.create(
            start: "2000-01-01 00:00:01 +0000",
            username: 'VYKZDK',
            mac: '',
            ap: '',
            siteIP: '',
            building_identifier: ''
          )
        end
      end

      it 'returns only the most recent 100 events' do
        get '/authentication/events/search/VYKZDK'

        expect(last_response.status).to eq(200)
        json_response = JSON.parse(last_response.body)
        expect(json_response.length).to eq(100)
        unique_dates = json_response.map { |session| session['start'] }.uniq
        expect(unique_dates).to eq(['2018-01-01 00:00:01 +0000'])
      end
    end
  end
end
