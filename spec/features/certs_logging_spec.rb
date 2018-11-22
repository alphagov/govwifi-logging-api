describe App do
  before do
    DB[:sessions].truncate
    DB[:userdetails].truncate
  end

  describe 'certificate post-auth logging' do
    shared_examples 'logging' do
      let(:post_auth_request) { get "/logging/post-auth/user/#{username}/cert-name/#{cert_name}/mac//ap//site//result/#{authentication_result}" }
      let(:cert_name) { URI.encode('Example Certificate Common Name') }
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
    let(:post_auth_request) { get "/logging/post-auth/user/#{username}/cert-name//cert-issuer//mac/#{mac}/ap//site//result/#{authentication_result}" }
    let(:authentication_result) { 'Access-Accept' }

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
