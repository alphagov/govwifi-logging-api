describe PerformancePlatform::Gateway::UniqueUsers do
  let(:session_repository) { DB[:sessions] }

  before do
    DB[:sessions].truncate
  end

  context 'stats for a week' do
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

      it 'includes sessions from less than a week ago' do
        session_repository.insert(
          username: 'john',
          start: Date.today - 8
        )

        expect(subject.fetch_stats).to eq(
          count: 2,
          metric_name: 'unique-users',
          period: 'week',
        )
      end
    end
  end
end
