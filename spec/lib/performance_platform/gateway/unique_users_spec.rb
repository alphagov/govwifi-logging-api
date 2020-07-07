describe PerformancePlatform::Gateway::UniqueUsers do
  subject { described_class.new(period: period) }

  let(:session_repository) { DB[:sessions] }
  let(:today_thursday) { Date.new(2018, 2, 1) }
  let(:eight_days_ago_wednesday) { Date.today - 8 }
  let(:six_days_ago_monday) { Date.new(2018, 1, 29) }
  let(:five_days_ago_saturday) { Date.new(2018, 1, 27) }
  let(:four_days_ago_sunday) { Date.new(2018, 1, 14) }
  let(:twenty_five_ago_friday) { Date.new(2018, 1, 5) }
  let(:thirty_four_days_ago_friday) { Date.new(2017, 12, 29) }

  before do
    DB[:sessions].truncate
    Timecop.freeze(Date.new(2018, 2, 1)) # THURSDAY
  end

  after do
    Timecop.return
  end

  context "Given sessions on weekends" do
    let(:period) { "week" }

    before do
      session_repository.insert(username: "bob", start: five_days_ago_saturday)
      session_repository.insert(username: "alice", start: four_days_ago_sunday)
    end

    it "assigns the metric name" do
      expect(subject.fetch_stats.fetch(:metric_name)).to eq("unique-users")
    end

    it "assigns period" do
      expect(subject.fetch_stats.fetch(:period)).to eq("week")
    end

    it "excludes weekends from the stats" do
      expect(subject.fetch_stats.fetch(:count)).to eq(0)
    end
  end

  context "Given sessions on weekends and weekdays" do
    let(:period) { "week" }

    before do
      session_repository.insert(username: "bob", start: five_days_ago_saturday)
      session_repository.insert(username: "alice", start: six_days_ago_monday)
    end

    it "counts only the weekdays" do
      expect(subject.fetch_stats.fetch(:count)).to eq(1)
    end
  end

  context "stats for a week" do
    let(:period) { "week" }

    context "given no sessions" do
      it "returns stats with zero unique users" do
        expect(subject.fetch_stats.fetch(:count)).to eq(0)
      end
    end

    context "given many sessions" do
      before do
        session_repository.insert(username: "bob", start: today_thursday)
        session_repository.insert(username: "alice", start: today_thursday)
        session_repository.insert(username: "jon", start: today_thursday)
      end

      it "returns unique user stats for sessions" do
        expect(subject.fetch_stats).to eq(
          count: 3,
          metric_name: "unique-users",
          period: "week",
        )
      end

      it "averages the statistics" do
        session_repository.insert(username: "sam", start: six_days_ago_monday)
        session_repository.insert(username: "betty", start: six_days_ago_monday)

        expect(subject.fetch_stats.fetch(:count)).to eq(2)
      end

      it "excludes sessions from more than a week ago" do
        session_repository.insert(username: "john", start: eight_days_ago_wednesday)
        expect(subject.fetch_stats.fetch(:count)).to eq(3)
      end
    end
  end

  context "stats for a month" do
    let(:period) { "month" }

    context "given no sessions" do
      it "returns stats with zero unique users" do
        expect(subject.fetch_stats).to eq(
          count: 0,
          metric_name: "unique-users",
          period: "month",
        )
      end
    end

    context "many monthly stats" do
      before do
        session_repository.insert(username: "bob", start: six_days_ago_monday)
        session_repository.insert(username: "kyle", start: six_days_ago_monday)
        session_repository.insert(username: "sally", start: six_days_ago_monday)
      end

      it "returns stats for unique users" do
        expect(subject.fetch_stats).to eq(
          count: 3,
          metric_name: "unique-users",
          period: "month",
        )
      end

      it "excludes stats from more than a month ago" do
        session_repository.insert(username: "bob", start: thirty_four_days_ago_friday)

        expect(subject.fetch_stats).to eq(
          count: 3,
          metric_name: "unique-users",
          period: "month",
        )
      end
    end

    context "Date override" do
      subject { described_class.new(period: "week", date: "2018-07-10") }

      before do
        session_repository.insert(
          username: "xyz123",
          start: "2018-07-09",
        )

        session_repository.insert(
          username: "abc987",
          start: "2018-08-09",
        )
      end

      it "uses the date argument" do
        expect(subject.fetch_stats).to eq(
          count: 1,
          metric_name: "unique-users",
          period: "week",
        )
      end
    end
  end
end
