describe Performance::UseCase::CompletionRate do
  let(:user_repo) { Class.new(Performance::Repository::SignUp) { unrestrict_primary_key } }
  let(:today) { Date.today }
  before do
    USER_DB[:userdetails].truncate

    # SMS self-registered outside of date scope, not logged in
    user_repo.create(
      username: "1",
      created_at: today - 10,
      contact: "+1234567890",
      sponsor: "+1234567890",
      last_login: nil,
    )

    # SMS self-registered outside of date scope and logged in
    user_repo.create(
      username: "2",
      created_at: today - 10,
      contact: "+1234567890",
      sponsor: "+1234567890",
      last_login: today,
    )

    # SMS self-registered within date scope not logged in
    user_repo.create(
      username: "3",
      created_at: today - 5,
      contact: "+2345678901",
      sponsor: "+2345678901",
      last_login: nil,
    )

    # SMS self-registered within date scope
    # and logged in
    user_repo.create(
      username: "4",
      created_at: today - 5,
      contact: "+2345678901",
      sponsor: "+2345678901",
      last_login: today,
    )

    # SMS sponsor-registered outside date scope not logged in
    user_repo.create(
      username: "5",
      created_at: today - 10,
      contact: "+2345678901",
      sponsor: "sponsor@example.com",
      last_login: nil,
    )

    # SMS sponsor-registered outside date scope logged in
    user_repo.create(
      username: "6",
      created_at: today - 10,
      contact: "+2345678901",
      sponsor: "sponsor@example.com",
      last_login: today,
    )

    # SMS sponsor-registered within date scope not logged in
    user_repo.create(
      username: "7",
      created_at: today - 5,
      contact: "+2345678901",
      sponsor: "sponsor@example.com",
      last_login: nil,
    )

    # SMS sponsor-registered within date scope
    # and logged in
    user_repo.create(
      username: "8",
      created_at: today - 5,
      contact: "+2345678901",
      sponsor: "sponsor@example.com",
      last_login: today,
    )

    # email self-registered outside scope not logged in
    user_repo.create(
      username: "9",
      created_at: today - 10,
      contact: "me@example.com",
      sponsor: "me@example.com",
      last_login: nil,
    )

    # Email self-registered outside scope and logged in
    user_repo.create(
      username: "10",
      created_at: today - 10,
      contact: "me@example.com",
      sponsor: "me@example.com",
      last_login: today,
    )

    # email self-registered within scope not logged in
    user_repo.create(
      username: "11",
      created_at: today - 5,
      contact: "me@example.com",
      sponsor: "me@example.com",
      last_login: nil,
    )

    # Email self-registered within scope and logged in
    user_repo.create(
      username: "12",
      created_at: today - 5,
      contact: "me@example.com",
      sponsor: "me@example.com",
      last_login: today,
    )
  end

  context "given completed signups and logins" do
    it "returns stats for completion rate" do
      expect(subject.fetch_stats).to eq(
        metric_name: "completion-rate",
        period: "week",
        all_registered: 6,
        all_logged_in: 3,
        sms_registered: 2,
        sms_logged_in: 1,
        email_registered: 2,
        email_logged_in: 1,
        sponsor_registered: 2,
        sponsor_logged_in: 1,
        cumulative_all_registered: 12,
        cumulative_all_logged_in: 6,
        cumulative_sms_registered: 4,
        cumulative_sms_logged_in: 2,
        cumulative_email_registered: 4,
        cumulative_email_logged_in: 2,
        cumulative_sponsor_registered: 4,
        cumulative_sponsor_logged_in: 2,
        date: today.to_s,
      )
    end
  end
end
