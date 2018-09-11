require 'rake'
require_relative '../../tasks/publish_statistics'

xdescribe 'synchronizing IPs and locations' do
  let(:ip_locations_table) { DB[:ip_locations] }

  before { ip_locations_table.truncate }

  context 'with none in the database' do
    it 'persists empty IPs and locations' do
      Rake::Task['synchronize_ip_locations'].invoke
      expect(ip_locations_table.count).to be_zero
    end
  end

  context 'with one in the database' do
    before do
      ip_locations_table.insert(ip: 1,location_id: 1)
    end

    it 'persists empty IPs and locations' do
      Rake::Task['synchronize_ip_locations'].invoke
      expect(ip_locations_table.count).to be_zero
    end
  end
end
