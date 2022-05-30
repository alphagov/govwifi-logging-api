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

  it "only uses sessions with a start date within the day specified" do
    sessions.insert(username: "AAAAAA", start: "2020-03-09 23:59:59")
    sessions.insert(username: "BBBBBB", start: "2020-03-10 00:00:00")
    sessions.insert(username: "CCCCCC", start: "2020-03-10 23:59:59")
    sessions.insert(username: "DDDDDD", start: "2020-03-11 00:00:00")
    userdetails.insert(username: "AAAAAA", last_login: nil)
    userdetails.insert(username: "BBBBBB", last_login: nil)
    userdetails.insert(username: "CCCCCC", last_login: nil)
    userdetails.insert(username: "DDDDDD", last_login: nil)

    subject.execute(date: Date.parse("2020-03-10"))

    expect(userdetails.first(username: "AAAAAA")[:last_login]).to be_nil
    expect(userdetails.first(username: "BBBBBB")[:last_login]).to eq(Time.parse("2020-03-10"))
    expect(userdetails.first(username: "CCCCCC")[:last_login]).to eq(Time.parse("2020-03-10"))
    expect(userdetails.first(username: "DDDDDD")[:last_login]).to be_nil
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
      userdetails.insert(username:, last_login: current_last_login)
      sessions.insert(username:, start: session_date)
    end

    def user
      userdetails.first(username:)
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

      it "counts the number of users updated" do
        expect(subject.execute(date: today)).to eq(1)
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
