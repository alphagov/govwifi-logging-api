require 'rake'
require_relative '../../tasks/publish_statistics'

describe 'synchronizing IPs and locations' do
  before { DB[:ip_locations].truncate }

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
    expect(DB[:ip_locations].count).to be_zero
  end

  context 'with existing IPs and locations in the database' do
    it 'overwrites them' do
      DB[:ip_locations].insert(ip: 1, location_id: 1)
      subject.execute
      expect(DB[:ip_locations].count).to be_zero
    end
  end
end
