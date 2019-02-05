describe App do
  before do
    DB[:sessions].truncate
    USER_DB[:userdetails].truncate
  end

  describe 'certificate post-auth logging with POST' do
    shared_examples 'logging' do
      let(:request_body) {
        {
          username: username,
          cert_name: cert_name,
          mac: nil,
          called_station_id: nil,
          site_ip_address: nil,
          authentication_result: authentication_result
        }.to_json
      }
      let(:post_auth_request) { post "/logging/post-auth", request_body }
      let(:cert_name) { 'Example Certificate Common Name' }
      let(:authentication_result) { 'Access-Accept' }

      before { post_auth_request }

      it 'a session' do
        expect(Session.count).to eq(1)
      end

      it 'the certificate common name' do
        expect(Session.first[:cert_name]).to eq('Example Certificate Common Name')
      end
    end

    context 'with a blank username' do
      let(:username) { '' }

      it_behaves_like 'logging'
    end

    context 'with a username' do
      let(:username) { 'fakeusername' }

      it_behaves_like 'logging'
    end
  end

  describe 'user/pass post-auth logging (on new endpoint)' do
    let(:username) { 'ABCDE' }
    let(:mac) { 'DA-59-19-8B-39-2D' }
    let(:authentication_result) { 'Access-Accept' }

    let(:request_body) {
      {
        username: username,
        cert_name: nil,
        mac: mac,
        called_station_id: nil,
        site_ip_address: nil,
        authentication_result: authentication_result
      }.to_json
    }
    let(:post_auth_request) { post "/logging/post-auth", request_body }

    before do
      User.create(username: username)
      post_auth_request
    end

    it 'writes a session' do
      expect(Session.count).to eq(1)
    end

    it 'writes the mac address' do
      expect(Session.first[:mac]).to eq(mac)
    end
  end
end
