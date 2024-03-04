describe Performance::UseCase::CompletionRate do
  let(:user_repo) { Class.new(Performance::Repository::SignUp) { unrestrict_primary_key } }
  let(:today) { "1 February 2020 1PM" }
  let(:period) { "day" }
  subject { described_class.new(date: Date.parse(today), period:).fetch_stats }
  before do
    USER_DB[:userdetails].truncate
  end
  describe "Timing" do
    describe "Day" do
      let(:period) { "day" }
      it "counts the users from yesterday" do
        FactoryBot.create_list(:user_details, 1, created_at: "1 February 2020 1PM")
        FactoryBot.create_list(:user_details, 2, created_at: "31 January 2020 1PM")
        FactoryBot.create_list(:user_details, 3, created_at: "30 January 2020 1PM")
        expect(subject).to include({ period: "day", all_registered: 2, cumulative_all_registered: 5 })
      end
    end
    describe "Week" do
      let(:period) { "week" }
      it "counts the users that signed up in the week before (31st - 25st including))" do
        FactoryBot.create_list(:user_details, 1, created_at: "1 February 2020 1PM")
        FactoryBot.create_list(:user_details, 2, created_at: "31 January 2020 1PM")
        FactoryBot.create_list(:user_details, 3, created_at: "26 January 2020 1PM")
        FactoryBot.create_list(:user_details, 4, created_at: "25 January 2020 1PM")
        FactoryBot.create_list(:user_details, 5, created_at: "24 January 2020 1PM")
        expect(subject).to include({ period: "week", all_registered: 9, cumulative_all_registered: 14 })
      end
    end
    describe "Month" do
      let(:period) { "month" }

      it "Counts the whole month of January" do
        FactoryBot.create_list(:user_details, 1, created_at: "1 February 2020 1PM")
        FactoryBot.create_list(:user_details, 2, created_at: "31 January 2020 1PM")
        FactoryBot.create_list(:user_details, 3, created_at: "2 January 2020 1PM")
        FactoryBot.create_list(:user_details, 4, created_at: "1 January 2020 1PM")
        FactoryBot.create_list(:user_details, 5, created_at: "31 December 2019 1PM")
        expect(subject).to include({ period: "month", all_registered: 9, cumulative_all_registered: 14 })
      end
    end
  end

  describe "Signup attributes" do
    let(:period) { "week" }
    before :each do
      FactoryBot.create(:user_details, :email, :active, created_at:)
      FactoryBot.create_list(:user_details, 2, :sms, :active, created_at:)
      FactoryBot.create_list(:user_details, 3, :sponsored, :active, created_at:)
      FactoryBot.create_list(:user_details, 4, :email, :inactive, created_at:)
      FactoryBot.create_list(:user_details, 5, :sms, :inactive, created_at:)
      FactoryBot.create_list(:user_details, 6, :sponsored, :inactive, created_at:)
    end
    describe "All / SMS / Email / Sponsored / Logged in / Registered" do
      let(:created_at) { "29 January 2020 1PM" }
      it "counts all signups" do
        expect(subject).to eq(
          period:,
          date: Date.parse(today).to_s,
          metric_name: "completion-rate",
          cumulative_all_registered: 21,
          cumulative_sms_registered: 7,
          cumulative_email_registered: 5,
          cumulative_sponsor_registered: 9,
          cumulative_all_logged_in: 6,
          cumulative_sms_logged_in: 2,
          cumulative_email_logged_in: 1,
          cumulative_sponsor_logged_in: 3,
          all_registered: 21,
          sms_registered: 7,
          email_registered: 5,
          sponsor_registered: 9,
          all_logged_in: 6,
          sms_logged_in: 2,
          email_logged_in: 1,
          sponsor_logged_in: 3,
        )
      end
    end

    describe "Cumulative vs within the period" do
      let(:created_at) { "1 January 2020 1PM" }
      it "does not count signups created further back than the specified period for non-cumulative attributes" do
        expect(subject).to eq(
          period:,
          date: Date.parse(today).to_s,
          metric_name: "completion-rate",
          cumulative_all_registered: 21,
          cumulative_sms_registered: 7,
          cumulative_email_registered: 5,
          cumulative_sponsor_registered: 9,
          cumulative_all_logged_in: 6,
          cumulative_sms_logged_in: 2,
          cumulative_email_logged_in: 1,
          cumulative_sponsor_logged_in: 3,
          all_registered: 0,
          sms_registered: 0,
          email_registered: 0,
          sponsor_registered: 0,
          all_logged_in: 0,
          sms_logged_in: 0,
          email_logged_in: 0,
          sponsor_logged_in: 0,
        )
      end
    end
  end
end
