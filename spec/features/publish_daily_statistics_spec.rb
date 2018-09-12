describe 'synchronizing IPs and locations' do
  let(:ip_locations) { DB[:ip_locations] }

  before { ip_locations.truncate }

  subject do
    source_gateway = PerformancePlatform::Gateway::S3IpLocations.new
    destination_gateway = PerformancePlatform::Gateway::SequelIPLocations.new
    PerformancePlatform::UseCase::SynchronizeIpLocations.new(
      source_gateway: source_gateway,
      destination_gateway: destination_gateway
    )
  end

  it 'saves empty IPs and locations' do
    subject.execute
    expect(ip_locations.count).to be_zero
  end

  context 'with existing IPs and locations in the database' do
    before { ip_locations.insert(ip: 1, location_id: 1) }

    it 'overwrites them' do
      subject.execute
      expect(ip_locations.count).to be_zero
    end
  end

  context 'three IPs and locations are in source' do
    let(:object_content) do
      [
        {
          ip: '127.0.0.1',
          location_id: 1
        }, {
          ip: '186.3.1.1',
          location_id: 2
        }, {
          ip: '186.3.4.6',
          location_id: 3
        }
      ]
    end

    let(:bucket) { 'StubBucket' }
    let(:key) { 'StubKey' }

    before do
      ENV['AWS_CONTAINER_CREDENTIALS_RELATIVE_URI'] = '/stubUri'

      stub_request(:get, 'http://169.254.170.2/stubUri').to_return(body: {
        'AccessKeyId': 'ACCESS_KEY_ID',
        'Expiration': (Time.now + 60).iso8601,
        'RoleArn': 'TASK_ROLE_ARN',
        'SecretAccessKey': 'SECRET_ACCESS_KEY',
        'Token': 'SECURITY_TOKEN_STRING'
      }.to_json)

      stub_request(:get, 'https://s3.eu-west-1.amazonaws.com/#{bucket}/#{key}') \
        .to_return(body: object_content.to_json)
    end

    it 'saves three IPs and locations' do
      subject.execute
      expect(ip_locations.count).to eq(3)
    end

    context 'with existing IPs and locations in the database' do
      before { ip_locations.insert(ip: '186.3.1.1', location_id: 1) }

      it 'overwrites them instead of adding to them' do
        subject.execute
        expect(ip_locations.count).to eq 3
      end
    end
  end
end
