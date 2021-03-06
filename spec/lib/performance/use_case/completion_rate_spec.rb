describe Performance::UseCase::CompletionRate do
  let(:user_repo) { Class.new(Performance::Repository::SignUp) { unrestrict_primary_key } }
  let(:today) { Date.today }
  before do
    USER_DB[:userdetails].truncate

    # Outside of date scope
    user_repo.create(
      username: "1",
      created_at: today - 1,
      contact: "+1234567890",
      sponsor: "+1234567890",
    )

    # Outside of date scope
    # and logged in
    user_repo.create(
      username: "2",
      created_at: today - 1,
      contact: "+1234567890",
      sponsor: "+1234567890",
      last_login: today,
    )

    # SMS self-registered within date scope
    user_repo.create(
      username: "3",
      created_at: today - 8,
      contact: "+2345678901",
      sponsor: "+2345678901",
    )

    # SMS self-registered within date scope
    # and logged in
    user_repo.create(
      username: "4",
      created_at: today - 8,
      contact: "+2345678901",
      sponsor: "+2345678901",
      last_login: today,
    )

    # SMS sponsor-registered within date scope
    user_repo.create(
      username: "5",
      created_at: today - 8,
      contact: "+2345678901",
      sponsor: "sponsor@example.com",
    )

    # SMS sponsor-registered within date scope
    # and logged in
    user_repo.create(
      username: "6",
      created_at: today - 8,
      contact: "+2345678901",
      sponsor: "sponsor@example.com",
      last_login: today,
    )

    # email self-registered within scope
    user_repo.create(
      username: "7",
      created_at: today - 10,
      contact: "me@example.com",
      sponsor: "me@example.com",
    )

    # Email self-registered within scope
    # and logged in
    user_repo.create(
      username: "8",
      created_at: today - 10,
      contact: "me@example.com",
      sponsor: "me@example.com",
      last_login: today,
    )

    # Email sponsored
    # and logged in
    user_repo.create(
      username: "9",
      created_at: today - 10,
      contact: "me@example.com",
      sponsor: "sponsor@example.com",
      last_login: today,
    )
  end

  context "given completed signups and logins" do
    it "returns stats for completion rate" do
      expect(subject.fetch_stats).to eq(
        metric_name: "completion-rate",
        period: "week",
        sms_registered: 2,
        sms_logged_in: 1,
        email_registered: 2,
        email_logged_in: 1,
        sponsor_registered: 3,
        sponsor_logged_in: 2,
        date: today.to_s,
      )
    end
  end
end
