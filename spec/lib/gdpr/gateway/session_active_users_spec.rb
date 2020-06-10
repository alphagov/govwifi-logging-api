require "date"

describe Gdpr::Gateway::Session do
  let(:subject) { described_class.new }
  let(:today) { Time.zone.today }
  let(:yesterday) { today.prev_day }
  let(:session) { DB[:sessions] }

  before do
    session.truncate
  end

  context "Without any session data" do
    it "finds no usernames" do
      expect(subject.active_users(date: today)).to eq([])
    end
  end

  context "With session data" do
    let(:username_today) { "bob" }
    let(:username_yesterday) { "alice" }

    before do
      2.times { session.insert(start: today, username: username_today) }
      2.times { session.insert(start: yesterday, username: username_yesterday) }
    end

    context "when searching through todays sessions" do
      it "finds todays username" do
        expect(subject.active_users(date: today)).to include(username_today)
      end

      it "does not find yesterdays username" do
        expect(subject.active_users(date: today)).not_to include(username_yesterday)
      end
    end

    context "when searching through yesterdays sessions" do
      it "finds yesterdays username" do
        expect(subject.active_users(date: yesterday)).to include(username_yesterday)
      end

      it "does not find todays username" do
        expect(subject.active_users(date: yesterday)).not_to include(username_today)
      end
    end
  end
end
