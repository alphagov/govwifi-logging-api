describe App do
  before do
    DB[:sessions].truncate
    DB[:userdetails].truncate
  end

  describe 'certificate post-auth logging' do
    shared_examples 'logs' do
      let(:mac) { 'DA-59-19-8B-39-2D' }
      let(:called_station_id) { '01-39-38-25-2A-80' }
      let(:site_ip_address) { '93.11.238.187' }
      let(:post_auth_request) { get "/logging/post-auth/user/#{username}/cert-name/#{cert_name}/cert-issuer/#{cert_issuer}/mac/#{mac}/ap/#{called_station_id}/site/#{site_ip_address}/result/#{authentication_result}" }
      let(:cert_name) { 'ExampleCertificateCommonName' }
      let(:cert_issuer) { 'ExampleOrganisation' }
      let(:authentication_result) { 'Access-Accept' }
      let(:session) { Session.first }

      before { post_auth_request }

      it 'writes a session' do
        expect(Session.count).to eq(1)
      end

      it 'writes the certificate common name' do
        expect(Session.first[:cert_name]).to eq('ExampleCertificateCommonName')
      end

      it 'writes the certificate issuing authority name' do
        expect(Session.first[:cert_issuer]).to eq('ExampleOrganisation')
      end
    end

    context 'with a blank username' do
      let(:username) { '' }

      it_behaves_like 'logs'
    end

    context 'with a username' do
      let(:username) { 'fakeusername' }

      it_behaves_like 'logs'
    end
  end

  describe 'user/pass post-auth logging (on new endpoint)' do
    let(:username) { 'ABCDE' }
    let(:mac) { 'DA-59-19-8B-39-2D' }
    let(:called_station_id) { '01-39-38-25-2A-80' }
    let(:site_ip_address) { '93.11.238.187' }
    let(:post_auth_request) { get "/logging/post-auth/user/#{username}/cert-name/#{cert_name}/cert-issuer/#{cert_issuer}/mac/#{mac}/ap/#{called_station_id}/site/#{site_ip_address}/result/#{authentication_result}" }
    let(:cert_name) { '' }
    let(:cert_issuer) { '' }
    let(:authentication_result) { 'Access-Accept' }
    let(:session) { Session.first }

    before do
      User.create(username: username)
      post_auth_request
    end

    it 'writes a session' do
      expect(Session.count).to eq(1)
    end

    it 'writes the certificate common name' do
      expect(Session.first[:mac]).to eq(mac)
    end
  end
end
