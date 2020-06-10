describe PerformancePlatform::Gateway::RoamingUsers do
  subject { described_class.new(period: period) }

  let(:location_ip_links) { DB[:ip_locations] }
  let(:sessions) { DB[:sessions] }
  let(:ip_1) { "7.7.7.7" }
  let(:ip_2) { "8.8.8.8" }
  let(:yesterday) { Time.zone.today - 1 }
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

  context "weekly" do
    it "adds the period to the payload" do
      expect(subject.fetch_stats.fetch(:period)).to eq("week")
    end

    context "given a user has visited more than 1 location" do
      it "counts as roaming" do
        create_session(ip_1, "alice", yesterday)
        create_session(ip_2, "alice", yesterday)

        expect(subject.fetch_stats.fetch(:roaming)).to eq(1)
        expect(subject.fetch_stats.fetch(:active)).to eq(1)
      end
    end

    context "given only some users have visited more than 1 location" do
      it "counts only those users as roaming" do
        create_session(ip_1, "alice", yesterday)
        create_session(ip_2, "alice", yesterday)
        create_session(ip_1, "sally", yesterday)
        create_session(ip_1, "john", yesterday)

        expect(subject.fetch_stats.fetch(:roaming)).to eq(1)
      end

      context "given users have only visited one location" do
        it "does not count them as roaming" do
          create_session(ip_1, "alice", yesterday)
          create_session(ip_1, "john", yesterday)

          expect(subject.fetch_stats.fetch(:roaming)).to eq(0)
        end
      end
    end

    context "given unsucessful logins" do
      it "does not count them as roaming" do
        create_session(ip_1, "alice", yesterday, 0)

        expect(subject.fetch_stats.fetch(:roaming)).to eq(0)
      end
    end
  end

  context "outside the timeframe" do
    context "week" do
      let(:period) { "week" }

      it "does not count them as roaming" do
        create_session(ip_1, "alice", Time.zone.today - 8)
        create_session(ip_2, "alice", Time.zone.today - 8)

        expect(subject.fetch_stats.fetch(:roaming)).to eq(0)
      end
    end

    context "month" do
      let(:period) { "month" }

      it "adds the period to the payload" do
        expect(subject.fetch_stats.fetch(:period)).to eq("month")
      end

      it "does not count them as roaming" do
        create_session(ip_1, "alice", Time.zone.today - 32)
        create_session(ip_2, "alice", Time.zone.today - 32)

        expect(subject.fetch_stats.fetch(:roaming)).to eq(0)
      end
    end
  end

private

  def create_session(ip, username, start, success = 1)
    sessions.insert(siteIP: ip, username: username, start: start, success: success)
  end
end
