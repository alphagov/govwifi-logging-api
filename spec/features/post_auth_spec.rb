describe App do
  describe 'POST post-auth' do
    context 'Access-Accept' do
      context 'HEALTH user' do
        it 'does not records the authentication request'
      end

      context 'GovWifi user' do
        it 'records the authentication request'
        it 'updates the users last login'
      end

      it 'returns a no-content header'
    end

    context 'Access-Reject' do
      it 'returns a 204 OK' do
      end
    end

    context 'Unknown' do
    it 'deals with an unknown result'
    end
  end
end
