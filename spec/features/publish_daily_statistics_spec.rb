describe "synchronizing IPs and locations" do
  let(:ip_locations) { DB[:ip_locations] }

  before do
    ENV["S3_PUBLISHED_LOCATIONS_IPS_BUCKET"] = "stub-bucket"
    ENV["S3_PUBLISHED_LOCATIONS_IPS_OBJECT_KEY"] = "stub-key"

    Aws.config = {
      stub_responses: {
        get_object: { body: object_content.to_json },
      },
    }

    ip_locations.truncate
  end

  subject do
    source_gateway = PerformancePlatform::Gateway::S3IpLocations.new
    destination_gateway = PerformancePlatform::Gateway::SequelIPLocations.new
    PerformancePlatform::UseCase::SynchronizeIpLocations.new(
      source_gateway: source_gateway,
      destination_gateway: destination_gateway,
    )
  end

  context "no IPs/locations are in source" do
    let(:object_content) { [] }

    it "saves empty IPs and locations" do
      subject.execute
      expect(ip_locations.count).to be_zero
    end

    context "with existing IPs and locations in the database" do
      before { ip_locations.insert(ip: 1, location_id: 1) }

      it "overwrites them" do
        subject.execute
        expect(ip_locations.count).to be_zero
      end
    end
  end

  context "three IPs and locations are in source" do
    let(:object_content) do
      [
        {
          ip: "127.0.0.1",
          location_id: 1,
        }, 
{
          ip: "186.3.1.1",
          location_id: 2,
        }, 
{
          ip: "186.3.4.6",
          location_id: 3,
        },
      ]
    end

    it "saves three IPs and locations" do
      subject.execute
      expect(ip_locations.count).to eq(3)
    end

    context "with existing IPs and locations in the database" do
      before { ip_locations.insert(ip: "186.3.1.1", location_id: 1) }

      it "overwrites them instead of adding to them" do
        subject.execute
        expect(ip_locations.count).to eq 3
      end
    end
  end
end
