require_relative "./s3_fake_client"

module Metrics
  describe IPSynchronizer do
    let(:ip_locations) do
      [{
        "ip": "127.0.0.1",
        "location_id": 1,
      },
       {
         "ip": "1.2.3.4",
         "location_id": 2,
       }]
    end

    let(:s3_client) do
      Metrics.fake_s3_client
    end

    before :each do
      ENV["S3_PUBLISHED_LOCATIONS_IPS_BUCKET"] = "stub-bucket"
      ENV["S3_PUBLISHED_LOCATIONS_IPS_OBJECT_KEY"] = "stub-key"

      allow(Services).to receive(:s3_client).and_return s3_client
      s3_client.put_object(key: ENV["S3_PUBLISHED_LOCATIONS_IPS_OBJECT_KEY"],
                           bucket: ENV["S3_PUBLISHED_LOCATIONS_IPS_BUCKET"],
                           body: ip_locations.to_json)

      DB[:ip_locations].truncate
    end

    describe "There are no locations" do
      let(:ip_locations) do
        []
      end

      it "saves no locations in the database" do
        IPSynchronizer.new.execute
        expect(DB[:ip_locations].all).to be_empty
      end
    end

    describe "S3 file contains ip addresses" do
      let(:ip_locations) do
        [{
          "ip": "127.0.0.1",
          "location_id": 1,
        },
         {
           "ip": "1.2.3.4",
           "location_id": 2,
         }]
      end

      it "saves the ip locations in the database" do
        IPSynchronizer.new.execute
        expect(DB[:ip_locations].all).to eq(ip_locations)
      end

      describe "There are already ip locations in the database" do
        let(:existing_ip_locations) do
          [{
            "ip": "127.0.0.1",
            "location_id": 1,
          },
           {
             "ip": "2.3.4.5",
             "location_id": 2,
           }]
        end

        it "replaces the existing ip locations" do
          existing_ip_locations.each do |location|
            DB[:ip_locations].insert(location)
          end
          expect {
            IPSynchronizer.new.execute
          }.to change {
            DB[:ip_locations].all
          }.from(existing_ip_locations)
            .to(ip_locations)
        end
      end
    end
  end
end
