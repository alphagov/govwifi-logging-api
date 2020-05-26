require "date"

describe Gdpr::UseCase::PopulateUserLastLogin do
  let(:subject) do
    described_class.new(
      session_gateway: Gdpr::Gateway::Session.new,
      last_login_gateway: Gdpr::Gateway::SetLastLogin.new,
    )
  end

  let(:today) { Date.today }
  let(:yesterday) { today.prev_day }
  let(:tomorrow) { today.next_day }

  let(:userdetails) { USER_DB[:userdetails] }
  let(:sessions) { DB[:sessions] }

  before do
    sessions.truncate
    userdetails.truncate
  end

  context "with no user sessions" do
    it "Does not fail" do
      expect { subject.execute(date: today) }.not_to raise_error
    end
  end

  context "with user sessions" do
    let(:username) { "jacob" }
    let(:current_last_login) { nil }
    let(:session_date) { today }

    before do
      userdetails.insert(username: username, last_login: current_last_login)
      sessions.insert(username: username, start: session_date)
    end

    def user
      userdetails.first(username: username)
    end

    context "when the user logs in for the first time" do
      let(:current_last_login) { nil }
      let(:session_date) { today }

      it "sets the last_login date to today" do
        subject.execute(date: today)
        expect(user[:last_login].to_date).to eq(today)
      end
    end

    context "when the user was logged in yesterday" do
      let(:current_last_login) { yesterday }
      let(:session_date) { today }

      it "sets the last_login date to today" do
        subject.execute(date: today)
        expect(user[:last_login].to_date).to eq(today)
      end
    end

    context "when the user was last logged in today" do
      let(:current_last_login) { today }
      let(:session_date) { today }

      it "sets the last_login date to today" do
        subject.execute(date: today)
        expect(user[:last_login].to_date).to eq(today)
      end
    end

    context "when backfilling last logins" do
      let(:current_last_login) { today }
      let(:session_date) { yesterday }

      it "does overrides the last login" do
        subject.execute(date: yesterday)
        expect(user[:last_login].to_date).to eq(yesterday)
      end
    end
  end
end
