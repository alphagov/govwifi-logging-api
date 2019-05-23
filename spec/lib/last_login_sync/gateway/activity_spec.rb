require 'date'

describe LastLoginSync::Gateway::Activity do
  let(:subject) { described_class.new }
  let(:today) { Date.today }
  let(:session) { DB[:sessions] }

  before do
    DB[:sessions].truncate
    #USER_DB[:userdetails].truncate
  end

  context 'Without any session data' do
    it 'finds no usernames' do
      expect(subject.since(date: today)).to eq([])
    end
  end

  context 'With session data' do
    let(:today_usernames) { %w[bob] }
    let(:yesterday_usernames) { %w[alice] }

    before do
      session.insert(start: Date.today, username: 'bob')
      session.insert(start: Date.today, username: 'bob')
      session.insert(start: Date.today.prev_day, username: 'alice')
      session.insert(start: Date.today.prev_day, username: 'alice')
    end

    it 'finds a username' do
      expect(subject.since(date: today)).to match_array(today_usernames)
    end

    it 'does not find yesterdays username' do
      expect(subject.since(date: today)).not_to match_array(yesterday_usernames)
    end

    context 'when looking for another date' do
      it 'finds usernames only from that date' do
        expect(subject.since(date: today.prev_day)).to match_array(yesterday_usernames)
      end
    end
  end
end
