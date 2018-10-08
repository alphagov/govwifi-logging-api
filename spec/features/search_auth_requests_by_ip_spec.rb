# frozen_string_literal: true

require 'date'

describe App do
  before do
    DB[:sessions].truncate
    DB[:userdetails].truncate
  end

  describe 'GET /auth_requests/search/ip' do
    context 'given no sessions for any IP' do
      it 'can retrieve no events' do
        get '/auth_requests/search/ip/1.1.1.1'

        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)).to eq([])
      end
    end

    context 'given one session for an IP' do
      before do
        Session.create(
          start: "2018-10-01 18:18:09 +0000",
          username: '',
          mac: '',
          ap: '',
          siteIP: '1.1.1.1',
          success: true,
          building_identifier: ''
        )
      end

      it 'can retrieve the IPs event' do
        get '/auth_requests/search/ip/1.1.1.1'

        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)).to eq(
          [
            {
              "ap" => "",
              "building_identifier" => "",
              "id" => 1,
              "mac" => "",
              "siteIP" => "1.1.1.1",
              "start" => "2018-10-01 18:18:09 +0000",
              "stop" => nil,
              "success" => true,
              "username" => ""
            }
          ]
        )
      end
    end
    #
    context 'given one session for two IPs' do
      before do
        Session.create(
          start: Time.now,
          username: '',
          mac: '',
          ap: '',
          siteIP: '1.1.1.1',
          success: true,
          building_identifier: ''
        )
        Session.create(
          start: Time.now,
          username: 'ZZZZZZ',
          mac: '',
          ap: '',
          siteIP: '2.2.2.2',
          success: true,
          building_identifier: ''
        )
      end

      it 'can retrieve the correct IPs event' do
        get '/auth_requests/search/ip/1.1.1.1'

        expect(last_response.status).to eq(200)
        json_response = JSON.parse(last_response.body)
        expect(json_response.length).to eq(1)
        expect(json_response.first['siteIP']).to eq('1.1.1.1')
      end
    end

    context 'given more than 100 sessions' do
      let(:start_of_today) { Date.today.to_time }
      let(:start_of_2018) { Date.new(2018).to_time }

      before do
        100.times do
          Session.create(
            start: start_of_today,
            username: '',
            mac: '',
            ap: '',
            siteIP: '1.1.1.1',
            success: true,
            building_identifier: ''
          )
        end

        2.times do
          Session.create(
            start: start_of_2018,
            username: '',
            mac: '',
            ap: '',
            siteIP: '1.1.1.1',
            success: true,
            building_identifier: ''
          )
        end

        get '/auth_requests/search/ip/1.1.1.1'
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
