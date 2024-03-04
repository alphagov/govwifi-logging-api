describe Performance::UseCase::NewUsers do
  let(:userdetails) { USER_DB[:userdetails] }
  let(:today) { Date.today }
  let(:period) { "month" }
  subject { Performance::UseCase::NewUsers.new(period:).fetch_stats }

  before do
    userdetails.truncate
    Timecop.freeze(Date.new(2024, 4, 1))
  end

  after do
    Timecop.return
  end

  describe "the period is weekly" do
    let(:period) { "week" }
    it { is_expected.to be_nil }
  end
  describe "the period is daily" do
    let(:period) { "day" }
    it { is_expected.to be_nil }
  end
  describe "active users" do
    it "counts an active user" do
      FactoryBot.create(:user_details, last_login: Date.new(2024, 3, 20), created_at: Date.new(2024, 3, 20))
      expect(subject[:new_inactive_users]).to eq(0)
      expect(subject[:new_active_users]).to eq(1)
    end
    it "does not count an active user outside the window" do
      FactoryBot.create(:user_details, last_login: Date.new(2024, 3, 20), created_at: Date.new(2024, 3, 1).prev_day)
      FactoryBot.create(:user_details, last_login: Date.new(2024, 3, 20), created_at: Date.new(2024, 3, 1))
      FactoryBot.create(:user_details, last_login: Date.new(2024, 3, 20), created_at: Date.new(2024, 3, 29))
      FactoryBot.create(:user_details, last_login: Date.new(2024, 3, 20), created_at: Date.new(2024, 3, 30))
      expect(subject[:new_inactive_users]).to eq(0)
      expect(subject[:new_active_users]).to eq(2)
    end
  end
  describe "inactive users" do
    before do
      FactoryBot.create(:user_details, last_login: nil, created_at: Date.new(2024, 2, 20))
    end
    it "counts an active user" do
      FactoryBot.create(:user_details, last_login: nil, created_at: Date.new(2024, 3, 20))
      expect(subject[:new_inactive_users]).to eq(1)
      expect(subject[:new_active_users]).to eq(0)
    end
    it "does not count an active user outside the window" do
      FactoryBot.create(:user_details, last_login: nil, created_at: Date.new(2024, 3, 1).prev_day)
      FactoryBot.create(:user_details, last_login: nil, created_at: Date.new(2024, 3, 1))
      FactoryBot.create(:user_details, last_login: nil, created_at: Date.new(2024, 3, 29))
      FactoryBot.create(:user_details, last_login: nil, created_at: Date.new(2024, 3, 30))
      expect(subject[:new_inactive_users]).to eq(2)
      expect(subject[:new_active_users]).to eq(0)
    end
  end
  it "counts the number of days in the window" do
    expect(subject[:days]).to eq(28)
  end
end
