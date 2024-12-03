describe Performance::UseCase::RoamingUsers do
  subject { described_class.new(period:, date: today) }

  let(:location_ip_links) { DB[:ip_locations] }
  let(:sessions) { DB[:sessions] }
  let(:ip_1) { "7.7.7.7" }
  let(:ip_2) { "8.8.8.8" }
  let(:today) { Date.today }
  let(:yesterday) { today - 1 }
  let(:period) { "week" }

  before do
    sessions.truncate
    location_ip_links.truncate

    location_ip_links.insert(ip: ip_1, location_id: 1)
    location_ip_links.insert(ip: ip_2, location_id: 2)
  end

  it "adds the metric name" do
    expect(subject.fetch_stats.fetch(:metric_name)).to eq("roaming-users")
  end

  it "adds the date" do
    expect(subject.fetch_stats.fetch(:date)).to eq(today.to_s)
  end

  context "weekly" do
    it "adds the period to the payload" do
      expect(subject.fetch_stats.fetch(:period)).to eq("week")
    end

    context "given a user has visited more than 1 location" do
      it "counts as roaming" do
        create(:session, siteIP: ip_1, username: "alice", start: yesterday)
        create(:session, siteIP: ip_2, username: "alice", start: yesterday)

        expect(subject.fetch_stats.fetch(:roaming)).to eq(1)
        expect(subject.fetch_stats.fetch(:active)).to eq(1)
      end
    end

    context "given only some users have visited more than 1 location" do
      it "counts only those users as roaming" do
        create(:session, siteIP: ip_1, username: "alice", start: yesterday)
        create(:session, siteIP: ip_2, username: "alice", start: yesterday)
        create(:session, siteIP: ip_1, username: "sally", start: yesterday)
        create(:session, siteIP: ip_1, username: "john", start: yesterday)

        expect(subject.fetch_stats.fetch(:roaming)).to eq(1)
      end

      context "given users have only visited one location" do
        it "does not count them as roaming" do
          create(:session, siteIP: ip_1, username: "alice", start: yesterday)
          create(:session, siteIP: ip_1, username: "john", start: yesterday)
          expect(subject.fetch_stats.fetch(:roaming)).to eq(0)
        end
      end
    end

    context "given unsucessful logins" do
      it "does not count them as roaming" do
        create(:session, :failed, start: yesterday)

        expect(subject.fetch_stats.fetch(:roaming)).to eq(0)
      end
    end
  end

  context "outside the timeframe" do
    context "week" do
      let(:period) { "week" }

      it "does not count them as roaming" do
        create_list(:session, 5, start: today - 8)
        expect(subject.fetch_stats.fetch(:roaming)).to eq(0)
      end
    end

    context "month" do
      let(:period) { "month" }

      it "adds the period to the payload" do
        expect(subject.fetch_stats.fetch(:period)).to eq("month")
      end

      it "does not count them as roaming" do
        create_list(:session, 5, start: today - 32)
        expect(subject.fetch_stats.fetch(:roaming)).to eq(0)
      end
    end
  end

  describe "cba users" do
    before :each do
      create_list(:session, 5, :cba, start: yesterday)
    end
    it "does not double count" do
      create_list(:session, 5, :cba, cert_issuer: "/CN=gov/C=uk", cert_serial: "12345", start: yesterday)
      expect(subject.fetch_stats.fetch(:cba)).to eq(6)
    end
    it "regards the same serial number, but different issuer as different certificates" do
      create_list(:session, 5, :cba, cert_serial: "12345", start: yesterday)
      expect(subject.fetch_stats.fetch(:cba)).to eq(10)
    end
    it "counts the number of cba users" do
      expect(subject.fetch_stats.fetch(:cba)).to eq(5)
    end
    it "disregards non-cba users" do
      create_list(:session, 3, start: yesterday)
      expect(subject.fetch_stats.fetch(:cba)).to eq(5)
    end
    it "disregards cba users outside the time frame" do
      create_list(:session, 3, :cba, start: today - 8)
      expect(subject.fetch_stats.fetch(:cba)).to eq(5)
    end
  end
end
