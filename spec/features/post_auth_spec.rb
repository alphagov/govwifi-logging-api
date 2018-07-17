describe App do
  before do
    DB[:sessions].truncate
    DB[:userdetails].truncate
  end

  describe 'POST post-auth' do
    let(:username) { 'vykzdx' }
    let(:mac) { 'DA-59-19-8B-39-2D' }
    let(:called_station_id) { '01-39-38-25-2a-80' }
    let(:site_ip_address) { '93.11.238.187' }
    let(:post_auth_request) { get "/logging/post-auth/user/#{username}/mac/#{mac}/ap/#{called_station_id}/site/#{site_ip_address}/result/#{authentication_result}" }
    let(:user) { User.find(username: username) }

    before do
      User.create(username: username)
      post_auth_request
    end

    context 'Access-Accept' do
      let(:authentication_result) { 'Access-Accept' }

      context 'GovWifi user' do
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

        context 'HEALTH user' do
          let(:username) { 'HEALTH' }

          it 'does not update the last login' do
            post_auth_request
            expect(user.last_login).to be_nil
          end

          it 'returns a 204 status code' do
            expect(last_response.status).to eq(204)
          end

          it 'does not create a session record' do
            expect(Session.count).to eq(0)
          end
        end

        context 'GovWifi user' do
          it 'updates the last login' do
            post_auth_request
            expect(user.last_login).to_not be_nil
          end
        end
      end

      context 'MAC Formatter' do
        let(:mac) { '50a67f849cd1' }
        it 'saves the MAC formatted' do
          expect(Session.last.mac).to eq('50-A6-7F-84-9C-D1')
        end
      end
    end

    context 'Access-Reject' do
      let(:authentication_result) { 'Access-Reject' }

      it 'does not record a session' do
        expect(Session.count).to eq(0)
      end

      it 'does not record last_login for the user' do
        post_auth_request
        expect(user.last_login).to be_nil
      end

      it 'returns a 204 OK' do
        expect(last_response.status).to eq(204)
      end
    end

    context 'Invalid authentication result' do
      context 'unknown string authentication result' do
        let(:authentication_result) { 'unknown' }

        it 'returns a 404 for anything other than Access-Accept or Access-Reject' do
          expect(Session.count).to eq(0)
          expect(last_response.status).to eq(404)
        end
      end

      context 'Blank authentication result' do
        let(:authentication_result) { '' }

        it 'returns a 404 for anything other than Access-Accept or Access-Reject' do
          expect(last_response.status).to eq(404)
        end
      end
    end
  end
end
