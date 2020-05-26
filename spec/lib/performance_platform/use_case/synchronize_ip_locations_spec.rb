describe PerformancePlatform::UseCase::SynchronizeIpLocations do
  subject do
    described_class.new(
      source_gateway: source_gateway,
      destination_gateway: destination_gateway,
    )
  end

  after do
    DB[:ip_locations].truncate
  end

  let(:source_gateway) { double(fetch: nil) }
  let(:destination_gateway) { double(save: nil) }

  before { subject.execute }

  it "fetches from the source gateway" do
    expect(source_gateway).to have_received(:fetch)
  end

  it "writes to the destination gateway" do
    expect(destination_gateway).to have_received(:save)
  end

  context "given results from the source gateway" do
    let(:results) do
      [
        {
          ip: "127.0.0.1",
          location_id: 1
        }
      ]
    end

    let(:source_gateway) { double(fetch: results) }

    it "passes results to the destination gateway" do
      expect(destination_gateway).to have_received(:save).with(results)
    end
  end
end
