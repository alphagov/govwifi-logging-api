describe Performance::UseCase::ActiveUsers do
  let(:sessions) { DB[:sessions] }
  let(:result) { subject.fetch_stats }
  let(:today) { Date.today }

  before do
    sessions.truncate
  end

  context "weekly active users" do
    subject { described_class.new(period: "week", date: today) }

    context "with users connecting once each in a week" do
      before do
        sessions.insert(
          siteIP: "12.12.12.12",
          username: "alice",
          start: today - 1,
          success: 1,
        )

        sessions.insert(
          siteIP: "12.12.12.12",
          username: "bob",
          start: today - 1,
          success: 1,
        )
      end

      it "counts each user" do
        expect(result).to eq(
          users: 2,
          metric_name: "active-users",
          period: "week",
          date: today.to_s,
        )
      end
    end

    context "with users connecting multiple times within a week" do
      before do
        sessions.insert(
          siteIP: "12.12.12.12",
          username: "alice",
          start: today - 1,
          success: 1,
        )

        sessions.insert(
          siteIP: "12.12.12.12",
          username: "alice",
          start: today - 2,
          success: 1,
        )
      end

      it "counts each user only once" do
        expect(result).to eq(
          users: 1,
          metric_name: "active-users",
          period: "week",
          date: today.to_s,
        )
      end
    end

    context "with users connecting outside the current week" do
      before do
        sessions.insert(
          siteIP: "12.12.12.12",
          username: "alice",
          start: today - 1,
          success: 1,
        )

        sessions.insert(
          siteIP: "12.12.12.12",
          username: "bob",
          start: today - 10,
          success: 1,
        )
      end

      it "does not count the users outside the week" do
        expect(result).to eq(
          users: 1,
          metric_name: "active-users",
          period: "week",
          date: today.to_s,
        )
      end
    end

    context "with access rejects" do
      before do
        sessions.insert(
          siteIP: "12.12.12.12",
          username: "alice",
          start: today - 1,
          success: 1,
        )

        sessions.insert(
          siteIP: "12.12.12.12",
          username: "bob",
          start: today - 1,
          success: 0,
        )
      end

      it "counts only the successful connections" do
        expect(result).to eq(
          users: 1,
          metric_name: "active-users",
          period: "week",
          date: today.to_s,
        )
      end
    end

    context "when the session was today" do
      before do
        sessions.insert(
          siteIP: "12.12.12.12",
          username: "alice",
          start: today,
          success: 1,
        )
      end

      it "only counts stats from the latest full day" do
        expect(result).to eq(
          users: 0,
          metric_name: "active-users",
          period: "week",
          date: today.to_s,
        )
      end
    end
  end

  context "monthly active users" do
    subject { described_class.new(period: "month", date: today) }

    context "with users connecting once each in a month" do
      before do
        sessions.insert(
          siteIP: "12.12.12.12",
          username: "alice",
          start: today - 1,
          success: 1,
        )

        sessions.insert(
          siteIP: "12.12.12.12",
          username: "bob",
          start: today - 26,
          success: 1,
        )
      end

      it "counts each user" do
        expect(result).to eq(
          users: 2,
          metric_name: "active-users",
          period: "month",
          date: today.to_s,
        )
      end
    end

    context "with users connecting multiple times within a month" do
      before do
        sessions.insert(
          siteIP: "12.12.12.12",
          username: "alice",
          start: today - 14,
          success: 1,
        )

        sessions.insert(
          siteIP: "12.12.12.12",
          username: "alice",
          start: today - 20,
          success: 1,
        )
      end

      it "counts each user only once" do
        expect(result).to eq(
          users: 1,
          metric_name: "active-users",
          period: "month",
          date: today.to_s,
        )
      end
    end

    context "with users connecting outside the current month" do
      before do
        sessions.insert(
          siteIP: "12.12.12.12",
          username: "alice",
          start: today - 33,
          success: 1,
        )

        sessions.insert(
          siteIP: "12.12.12.12",
          username: "bob",
          start: today - 36,
          success: 1,
        )
      end

      it "does not count the users outside the month" do
        expect(result).to eq(
          users: 0,
          metric_name: "active-users",
          period: "month",
          date: today.to_s,
        )
      end
    end
  end
end
