describe PerformancePlatform::Gateway::AccountUsage do
  let(:session_repository) { DB[:sessions] }
  let(:site_repository) { DB[:site] }
  let(:site_ip_repository) { DB[:siteip] }

  before do
    DB[:sessions].truncate
    DB[:siteip].truncate
    DB[:site].truncate
  end

  context 'given no sessions' do
    it 'returns stats with zero sessions' do
      expect(subject.fetch_stats).to eq(
        total: 0,
        transactions: 0,
        roaming: 0,
        one_time: 0,
        metric_name: 'account-usage',
        period: 'day',
      )
    end
  end

  context 'given many sessions' do
    before do
      session_repository.insert(
        siteIP: '127.0.0.1',
        username: 'bob',
        start: Date.today - 1
      )

      session_repository.insert(
        siteIP: '127.0.0.9',
        username: 'bob',
        start: Date.today - 1
      )

      session_repository.insert(
        siteIP: '127.0.0.1',
        username: 'bob',
        start: Date.today - 1
      )

      session_repository.insert(
        siteIP: '127.0.0.9',
        username: 'alice',
        start: Date.today - 1
      )

      session_repository.insert(
        siteIP: '127.0.0.9',
        username: 'alice',
        start: Date.today - 2
      )

      site1_id = site_repository.insert(
        address: 'hello',
        org_id: 1
      )

      site2_id = site_repository.insert(
        address: 'foo',
        org_id: 2
      )

      site_ip_repository.insert(
        ip: '127.0.0.1',
        site_id: site1_id
      )

      site_ip_repository.insert(
        ip: '127.0.0.9',
        site_id: site2_id
      )
    end

    it 'returns stats for sessions' do
      expect(subject.fetch_stats).to eq(
        total: 2,
        transactions: 3,
        roaming: 1,
        one_time: 1,
        metric_name: 'account-usage',
        period: 'day',
      )
    end
  end
end
