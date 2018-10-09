# frozen_string_literal: true

require 'date'

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
          success: true,
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
              "success" => true,
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
          success: true,
          building_identifier: ''
        )
        Session.create(
          start: Time.now,
          username: 'ZZZZZZ',
          mac: '',
          ap: '',
          siteIP: '',
          success: true,
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

    context 'given sessions that are older than two weeks' do
      let(:start_of_today) { Date.today.to_time }
      let(:start_of_2018) { Date.new(2018).to_time }

      before do
        100.times do
          Session.create(
            start: start_of_today,
            username: 'VYKZDK',
            mac: '',
            ap: '',
            siteIP: '',
            success: true,
            building_identifier: ''
          )
        end

        2.times do
          Session.create(
            start: start_of_2018,
            username: 'VYKZDK',
            mac: '',
            ap: '',
            siteIP: '',
            success: true,
            building_identifier: ''
          )
        end

        get '/authentication/events/search/VYKZDK'
      end

      it 'returns only 100 events' do
        json_response = JSON.parse(last_response.body)
        expect(json_response.length).to eq(100)
      end

      it 'does not return the events more than two weeks old' do
        json_response = JSON.parse(last_response.body)
        parsed_dates = json_response.map do |session|
          Time.parse(session['start']).to_i
        end
        unique_dates = parsed_dates.uniq

        expect(unique_dates).to eq([start_of_today.to_i])
      end
    end
  end
end
