describe PerformancePlatform::Gateway::AccountUsage do
  let(:sessions) { DB[:sessions] }
  let(:locations) { DB[:site] }
  let(:location_ip_links) { DB[:siteip] }

  let(:ip_A1) { '104.24.112.118' }
  let(:ip_A2) { '104.24.112.120' }
  let(:ip_B1) { '216.58.201.46' }
  let(:ip_B2) { '216.58.201.49' }

  let(:result) { subject.fetch_stats }

  subject { described_class.new(period: 'week') }

  before do
    sessions.truncate
    locations.truncate
    location_ip_links.truncate

    location_a = locations.insert(address: 'House One', org_id: 1)
    location_b = locations.insert(address: 'House Two', org_id: 1)

    location_ip_links.insert(ip: ip_A1, site_id: location_a)
    location_ip_links.insert(ip: ip_A2, site_id: location_a)
    location_ip_links.insert(ip: ip_B1, site_id: location_b)
    location_ip_links.insert(ip: ip_B2, site_id: location_b)
  end

  describe 'one user' do
    context 'with one session' do
      before do
        sessions.insert(
          siteIP: ip_A1,
          username: 'alice',
          start: Date.today - 1
        )
      end

      it 'generates correct stats' do
        expect(result[:total]).to eq(1)
        expect(result[:transactions]).to eq(1)
        expect(result[:roaming]).to eq(0)
        expect(result[:one_time]).to eq(1)
      end

      it 'generates correct tags' do
        expect(result[:metric_name]).to eq('account-usage')
        expect(result[:period]).to eq('week')
      end
    end

    context 'with two sessions' do
      before do
        sessions.insert(
          siteIP: first_ip,
          username: 'alice',
          start: Date.today - 1
        )

        sessions.insert(
          siteIP: second_ip,
          username: 'alice',
          start: Date.today - 1
        )
      end

      context 'on the same IP' do
        let(:first_ip) { ip_A1 }
        let(:second_ip) { first_ip }

        it 'generates correct stats' do
          expect(result[:total]).to eq(1)
          expect(result[:transactions]).to eq(1)
          expect(result[:roaming]).to eq(0)
          expect(result[:one_time]).to eq(1)
        end
      end

      context 'on different IPs within the same location' do
        let(:first_ip) { ip_A1 }
        let(:second_ip) { ip_A2 }

        it 'generates correct stats' do
          expect(result[:total]).to eq(1)
          expect(result[:transactions]).to eq(1)
          expect(result[:roaming]).to eq(0)
          expect(result[:one_time]).to eq(1)
        end
      end

      context 'on different IPs across different locations' do
        let(:first_ip) { ip_A1 }
        let(:second_ip) { ip_B1 }

        it 'generates correct stats' do
          expect(result[:total]).to eq(1)
          expect(result[:transactions]).to eq(2)
          expect(result[:roaming]).to eq(1)
          expect(result[:one_time]).to eq(0)
        end
      end
    end
  end

  describe 'two users' do
    context 'neither roaming' do
      before do
        sessions.insert(
          siteIP: ip_A1,
          username: 'alice',
          start: Date.today - 1
        )

        sessions.insert(
          siteIP: ip_A2,
          username: 'bob',
          start: Date.today - 1
        )
      end

      it 'generates correct stats' do
        expect(result[:total]).to eq(2)
        expect(result[:transactions]).to eq(2)
        expect(result[:roaming]).to eq(0)
        expect(result[:one_time]).to eq(2)
      end
    end

    context 'one roaming, one not' do
      before do
        sessions.insert(
          siteIP: ip_A1,
          username: 'alice',
          start: Date.today - 1
        )

        sessions.insert(
          siteIP: ip_B1,
          username: 'alice',
          start: Date.today - 1
        )

        sessions.insert(
          siteIP: ip_A2,
          username: 'bob',
          start: Date.today - 1
        )
      end

      it 'generates correct stats' do
        expect(result[:total]).to eq(2)
        expect(result[:transactions]).to eq(3)
        expect(result[:roaming]).to eq(1)
        expect(result[:one_time]).to eq(1)
      end
    end

    context 'both roaming' do
      before do
        sessions.insert(
          siteIP: ip_A1,
          username: 'alice',
          start: Date.today - 1
        )

        sessions.insert(
          siteIP: ip_B1,
          username: 'alice',
          start: Date.today - 1
        )

        sessions.insert(
          siteIP: ip_A2,
          username: 'bob',
          start: Date.today - 1
        )

        sessions.insert(
          siteIP: ip_B2,
          username: 'bob',
          start: Date.today - 1
        )
      end

      it 'generates correct stats' do
        expect(result[:total]).to eq(2)
        expect(result[:transactions]).to eq(4)
        expect(result[:roaming]).to eq(2)
        expect(result[:one_time]).to eq(0)
      end
    end
  end

  context 'zero sessions' do
    it 'generates the correct (empty) stats' do
      expect(subject.fetch_stats).to eq(
        total: 0,
        transactions: 0,
        roaming: 0,
        one_time: 0,
        metric_name: 'account-usage',
        period: 'week',
      )
    end
  end

  context 'a session two days ago' do
    before do
      sessions.insert(
        siteIP: ip_A1,
        username: 'bob',
        start: Date.today - 2
      )
    end

    it 'generates the correct (empty) stats' do
      expect(subject.fetch_stats).to eq(
        total: 0,
        transactions: 0,
        roaming: 0,
        one_time: 0,
        metric_name: 'account-usage',
        period: 'week',
      )
    end
  end
end
