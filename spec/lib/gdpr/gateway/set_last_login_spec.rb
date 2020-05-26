require "date"

describe Gdpr::Gateway::SetLastLogin do
  let(:subject) { described_class.new }
  let(:username) { "borris" }
  let(:today) { Date.today }
  let(:yesterday) { today.prev_day }
  let(:tomorrow) { today.next_day }
  let(:userdetails) { USER_DB[:userdetails] }

  before do
    USER_DB[:userdetails].truncate
  end

  context "with a username" do
    let(:current_last_login) { nil }
    before do
      userdetails.insert(username: username, last_login: current_last_login)
    end

    it "sets the last_login date" do
      subject.set(date: today, usernames: [username])
      expect(userdetails.first(username: username)[:last_login].to_date).to eq(today)
    end

    context "when last_login already set" do
      context "when last_login is currently in the past" do
        let(:current_last_login) { yesterday }

        it "updates last_login" do
          subject.set(date: today, usernames: [username])
          expect(userdetails.first(username: username)[:last_login].to_date).to eq(today)
        end
      end
    end
  end

  context "without any sessions" do
    it "does not fail" do
      expect { subject.set(date: today, usernames: [username]) }.not_to raise_error
    end
  end
end
