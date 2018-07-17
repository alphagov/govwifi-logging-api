describe App do
  before do
    DB[:sessions].truncate
  end

  describe 'POST post-auth' do
    let(:username) { 'vykzdx' }
    let(:mac) { 'da-59-19-8b-39-2d' }
    let(:called_station_id) { '01-39-38-25-2a-80' }
    let(:site_ip_address) { '93.11.238.187' }

    context 'Access-Accept' do
      let(:authentication_result) { 'Access-Accept' }

      context 'GovWifi user' do
        before do
          get "/logging/post-auth/user/#{username}/mac/#{mac}/ap/#{called_station_id}/site/#{site_ip_address}/result/#{authentication_result}"
        end

        it 'creates a single session record' do
          expect(Session.count).to eq(1)
        end

        it 'records the session details' do
          session = Session.first

          expect(session.username).to eq(username)
          expect(session.mac).to eq(mac)
          expect(session.ap).to eq(called_station_id)
          expect(session.siteIP).to eq(site_ip_address)
          expect(session.building_identifier).to eq(called_station_id)
        end

        it 'updates the users last login'
      end

      context 'HEALTH user' do
        it 'does not records the authentication request'
      end

      it 'returns a no-content header'
    end

    context 'Access-Reject' do
      it 'returns a 204 OK'
    end

    context 'Unknown' do
      it 'deals with an unknown result'
    end

    context 'Invalid URL format' do
    end
  end
end
