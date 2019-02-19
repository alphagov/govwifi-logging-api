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
    let(:cert_name) { '' }
    let(:post_auth_request) { get "/logging/post-auth/user/#{username}/cert-name/#{cert_name}/mac/#{mac}/ap/#{called_station_id}/site/#{site_ip_address}/result/#{authentication_result}" }
    let(:user) { User.find(username: username) }
    let(:session) { Session.first }

    before do
      User.create(username: username)
      post_auth_request
    end

    shared_examples 'it saves the right logging information' do
      context 'GovWifi user' do
        it 'creates a single session record' do
          expect(Session.count).to eq(1)
        end

        context 'given a certificate authentication' do
          let(:cert_name) { 'some_cert_name' }

          it 'records the cert name' do
            expect(session.cert_name).to eq(cert_name)
          end
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
      end

      context 'MAC Formatter' do
        let(:mac) { '50a67f849cd1' }
        it 'saves the MAC formatted' do
          expect(Session.last.mac).to eq('50-A6-7F-84-9C-D1')
        end
      end
    end

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

    context 'Invalid authentication result' do
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

      context 'Non existent route' do
        let(:post_auth_request) { get '/some-path/that/does/not/exist' }
        it 'returns a 204 regardless of defined routes' do
          expect(last_response.status).to eq(204)
        end
      end
    end
  end

  context 'given a username longer than 6 characters' do
    it 'stops the error from blowing up' do
      username = "very_long_username"
      get "/logging/post-auth/user/#{username}/cert-name//mac//ap//site//result/success"
    end
  end
end
