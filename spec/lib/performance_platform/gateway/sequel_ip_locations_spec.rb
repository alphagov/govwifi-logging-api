describe PerformancePlatform::Gateway::SequelIPLocations do
  let(:locations) { DB[:ip_locations] }

  before { subject.save(data) }

  context "with no data" do
    let(:data) { [] }

    it "saves no ip/locations" do
      expect(locations.count).to be_zero
    end
  end

  context "with three ip/locations" do
    let(:data) do
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

    it "saves those ip/locations" do
      expect(locations.count).to eq(3)
    end
  end
end
