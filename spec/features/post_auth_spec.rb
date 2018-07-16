describe App do
  describe 'Post Authentication' do
    let(:username) { 'bob' }
    let(:calling_station_id) { 'Z4-19-C2-18-2B-27' }
    let(:called_station_id) { 'C3-23-A2-38-9C-38' }
    let(:client_ip_address) { '127.0.0.1' }
    let(:authentication_result) { 'Access-Accept' }

    it 'Logs to the sessions table' do
      get "/logging/post-auth/user/#{username}/mac/#{calling_station_id}/ap/#{called_station_id}/site/#{client_ip_address}/result/#{authentication_result}"

      expect(last_response).to be_ok
    end
  end
end
