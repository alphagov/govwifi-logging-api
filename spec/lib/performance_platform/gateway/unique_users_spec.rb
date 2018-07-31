describe PerformancePlatform::Gateway::UniqueUsers do
  let(:session_repository) { DB[:sessions] }

  before do
    DB[:sessions].truncate
    Timecop.freeze(Date.new(2018, 2, 1))
  end

  after do
    Timecop.return
  end

  context 'stats for a week' do
    subject { described_class.new(period: 'week') }

    context 'given no sessions' do
      it 'returns stats with zero unique users' do
        expect(subject.fetch_stats).to eq(
          count: 0,
          metric_name: 'unique-users',
          period: 'week',
        )
      end
    end

    context 'given many sessions' do
      before do
        session_repository.insert(
          username: 'bob',
          start: Date.today
        )

        session_repository.insert(
          username: 'alice',
          start: Date.today
        )

        session_repository.insert(
          username: 'alice',
          start: Date.today
        )
      end

      it 'returns unique user stats for sessions' do
        expect(subject.fetch_stats).to eq(
          count: 2,
          metric_name: 'unique-users',
          period: 'week',
        )
      end

      it 'excludes sessions from more than a week ago' do
        session_repository.insert(
          username: 'john',
          start: Date.today - 8
        )

        expect(subject.fetch_stats.fetch(:count)).to eq(2)
      end
    end
  end

  context 'stats for a month' do
    subject { described_class.new(period: 'month') }

    context 'given no sessions' do
      it 'returns stats with zero unique users' do
        expect(subject.fetch_stats).to eq(
          count: 0,
          metric_name: 'unique-users',
          period: 'month',
        )
      end
    end

    context 'with 2 signups last month and 1 this month' do
      before do
        session_repository.insert(
          username: 'alice',
          start: Date.today
        )

        session_repository.insert(
          username: 'alice',
          start: Date.today
        )

        session_repository.insert(
          username: 'bob',
          start: Date.new(2018, 1, 5)
        )

        session_repository.insert(
          username: 'kyle',
          start: Date.new(2018, 1, 26)
        )
      end

      it 'returns stats for unique users' do
        expect(subject.fetch_stats).to eq(
          count: 3,
          metric_name: 'unique-users',
          period: 'month',
        )
      end
    end

    context 'with sessions on Friday, Saturday and Sunday' do
      before do
        session_repository.insert(
          username: 'bob',
          start: Date.new(2018, 1, 27) # Saturday
        )

        session_repository.insert(
          username: 'alice',
          start: Date.new(2018, 1, 14) # Sunday
        )

        session_repository.insert(
          username: 'kyle',
          start: Date.new(2018, 1, 5) # Friday
        )
      end

      it 'does not take weekends into account' do
        expect(subject.fetch_stats).to eq(
          count: 1,
          metric_name: 'unique-users',
          period: 'month',
        )
      end
    end
  end
end
