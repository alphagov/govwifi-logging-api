describe App do
  before do
    DB[:sessions].truncate
    DB[:userdetails].truncate
  end

  describe 'POST post-auth' do
    let(:username) { 'VYKZDX' }
    let(:mac) { 'DA-59-19-8B-39-2D' }
    let(:called_station_id) { '01-39-38-25-2A-80' }
    let(:site_ip_address) { '93.11.238.187' }
    let(:post_auth_request) { get "/logging/post-auth/user/#{URI.encode(username)}/mac/#{mac}/ap/#{called_station_id}/site/#{site_ip_address}/result/#{authentication_result}" }
    let(:user) { User.find(username: username) }
    let(:session) { Session.first }

    shared_examples 'it saves the right logging information' do
      before { post_auth_request }

      it 'creates a single session record' do
        expect(Session.count).to eq(1)
      end

      context 'given a lowercase username' do
        let(:username) { 'abcdef' }

        it 'ensures that the username is saved in uppercase' do
          expect(session.username).to eq('ABCDEF')
        end
      end

      it 'records the start time of the session' do
        expect(session.start).to_not be_nil
      end

      it 'records the session details' do
        expect(session.username).to eq(username)
        expect(session.mac).to eq(mac)
        expect(session.ap).to eq(called_station_id)
        expect(session.siteIP).to eq(site_ip_address)
      end

      context 'Given the "Called Station ID" is an MAC address' do
        let(:called_station_id) { '01-39-38-25-2A-80' }

        it 'saves it as the access point' do
          expect(session.ap).to eq(called_station_id)
        end

        it 'does not save it as the building identifier' do
          expect(session.building_identifier).to be_nil
        end

        context 'Given the Called Station ID needs to be formatted' do
          let(:called_station_id) { 'aa-bb-cc-25-2a-80' }

          it 'formats the Called Station ID' do
            expect(session.ap).to eq('AA-BB-CC-25-2A-80')
          end
        end

        context 'Given a Called Station ID has extra trailing characters' do
          let(:called_station_id) { 'C4-13-E2-22-DC-55%3ASTAGING-GovWifi' }

          it 'Formats it and considers it a valid access point' do
            expect(session.ap).to eq('C4-13-E2-22-DC-55')
            expect(session.building_identifier).to be_nil
          end
        end
      end

      context 'Given the "Called Station ID" is a building identifier' do
        let(:called_station_id) { 'Building-Identifier' }

        it 'saves it as a building identifier' do
          expect(session.building_identifier).to eq(called_station_id)
        end

        it 'does not save it as an access point' do
          expect(session.ap).to eq('')
        end
      end

      context 'Given a blank "Called Station ID"' do
        let(:called_station_id) { '' }

        it 'does not save the ap' do
          expect(session.ap).to eq('')
        end

        it 'does not save the building_identifier' do
          expect(session.building_identifier).to be_nil
        end
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

      context 'MAC Formatter' do
        let(:mac) { '50a67f849cd1' }
        it 'saves the MAC formatted' do
          expect(Session.last.mac).to eq('50-A6-7F-84-9C-D1')
        end
      end
    end

    context 'with a pre-existing user' do
      before { User.create(username: username) }

      context 'Access-Accept' do
        let(:authentication_result) { 'Access-Accept' }

        it_behaves_like 'it saves the right logging information'

        it 'updates the user last login' do
          post_auth_request
          expect(user.last_login).to_not be_nil
        end

        it 'sets success to true' do
          post_auth_request
          expect(Session.last.success).to eq(true)
        end
      end

      context 'Access-Reject' do
        let(:authentication_result) { 'Access-Reject' }

        it_behaves_like 'it saves the right logging information'

        it 'does not update the user last login' do
          post_auth_request
          expect(user.last_login).to be_nil
        end

        it 'sets success to false' do
          post_auth_request
          expect(Session.last.success).to eq(false)
        end
      end
    end

    context 'without a user record (certs)' do
      before { post_auth_request }

      let(:authentication_result) { 'Access-Accept' }

      context 'given a max length certificate common name' do
        let(:username) { 'A Max Length Certificate Common Name Really 64 Characters Long' }

        it 'saves the username' do
          expect(session.username).to eq(username.upcase)
        end
      end
    end

    context 'Invalid authentication result' do
      before { post_auth_request }

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

      context 'Given parameters are missing from the GET request' do
        let(:authentication_result) { 'Access-Accept' }
        let(:username) { '' }
        let(:called_station_id) { '' }
        let(:site_ip_address) { '' }

        it 'returns a 204 status code' do
          expect(last_response.status).to eq(204)
        end

        it 'creates a session record' do
          expect(Session.all.count).to eq(1)
        end
      end
    end
  end
end
