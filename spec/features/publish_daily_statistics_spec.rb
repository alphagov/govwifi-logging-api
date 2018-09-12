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

  xcontext 'three IPs and locations are in source' do
    before do
      # webmock s3 here?
    end

    it 'saves three IPs and locations' do
      subject.execute
      expect(ip_locations.count).to be_zero
    end

    context 'with existing IPs and locations in the database' do
      before { ip_locations.insert(ip: 1, location_id: 1) }

      it 'overwrites them instead of adding to them' do
        subject.execute
        expect(ip_locations.count).to eq 3
      end
    end
  end
end
