# frozen_string_literal: true

require_relative "./s3_fake_client"

describe Metrics::ActiveUsers do
  let(:today) { Date.today }
  let(:earlier_today) { Date.today - 0.5 }
  let(:yesterday) { today - 1 }
  let(:last_month) { today - 31 }
  let(:period) { "week" }
  let(:s3_client) { Metrics.fake_s3_client }

  subject do
    Metrics::ActiveUsers.new(period: period,
                             date: today.to_s)
  end

  before do
    ENV["S3_METRICS_BUCKET"] = "stub-bucket"
    DB[:sessions].truncate
    USER_DB[:userdetails].truncate
    allow(Services).to receive(:s3_client).and_return s3_client
  end

  it "rejects invalid periods" do
    expect { Metrics::ActiveUsers.new(period: "foo", date: Date.today.to_s) }
      .to raise_error(ArgumentError)
  end

  describe "#execute" do
    before do
      session_params = { "start" => start_date,
                         "stop" => today,
                         "siteIP" => "1.2.3.4",
                         "success" => 1,
                         "username" => "User" }

      Session.create(session_params)

      subject.to_s3

      result = s3_client.get_object(bucket: ENV.fetch("S3_METRICS_BUCKET"), key: subject.key).body.read
      parsed_result = JSON.parse(result)
      @active_users = parsed_result["users"]
    end

    describe "The start date is yesterday and the period is a week" do
      let(:start_date) { yesterday }
      let(:period) { "week" }

      it "uploads 1 active user to S3" do
        expect(@active_users).to eq(1)
      end
    end

    describe "The start date is a month ago and the period is a week" do
      let(:start_date) { last_month }
      let(:period) { "week" }

      it "uploads 0 active users to S3" do
        expect(@active_users).to eq(0)
      end
    end

    describe "The start date is a month ago and the period is a day" do
      let(:start_date) { last_month }
      let(:period) { "day" }

      it "uploads 0 active and 0 roaming users to S3" do
        expect(@active_users).to eq(0)
      end
    end

    describe "The start date is earlier today and the period is a day" do
      let(:start_date) { today - 0.5 }
      let(:period) { "day" }

      it "uploads 1 active user to S3" do
        expect(@active_users).to eq(1)
      end
    end
  end
end
