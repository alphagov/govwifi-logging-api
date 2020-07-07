# frozen_string_literal: true

describe Metrics::ActiveUsers do
  subject { Metrics::ActiveUsers.new(period: "month", date: Date.today.to_s) }

  before do
    @s3_client_double = double

    allow(@s3_client_double).to receive(:put_object)
    allow(Aws::S3::Client).to receive(:new).and_return(@s3_client_double)
  end

  it "stores the date" do
    expect(subject.period).to eq "month"
  end

  it "stores the period" do
    expect(subject.date).to eq Date.today.to_s
  end

  it "rejects invalid periods" do
    expect { Metrics::ActiveUsers.new(period: "foo", date: Date.today.to_s) }
      .to raise_error(ArgumentError)
  end

  describe "generate!" do
    before do
      @gateway_double = instance_double(
        PerformancePlatform::Gateway::ActiveUsers,
      )

      allow(@gateway_double).to receive(:fetch_stats).and_return :result
      allow(PerformancePlatform::Gateway::ActiveUsers)
        .to receive(:new)
        .and_return @gateway_double

      subject.generate!
    end

    it "delegates to the performance platform gateway" do
      expect(PerformancePlatform::Gateway::ActiveUsers)
        .to have_received(:new)
        .with(period: subject.period, date: subject.date)

      expect(@gateway_double)
        .to have_received(:fetch_stats)
    end

    it "stores the result in an instance variable" do
      expect(subject.report).to eq :result
    end
  end

  describe "key" do
    it "returns a key for the S3 upload" do
      expect(subject.key)
        .to eq "active-users-#{subject.period}-#{subject.date}"
    end
  end

  describe "publish!" do
    before do
      data = double

      allow(data).to receive_message_chain("to_json.to_s").and_return :payload
      allow(subject).to receive(:report).and_return data
      allow(subject).to receive(:key).and_return :some_key

      ENV["S3_METRICS_BUCKET"] = "stub-bucket"
    end

    context "when the report is nil" do
      it "throws an error" do
        expect { subject.publish! }.to raise_error(/call generate!/)
      end
    end

    context "when the report has been generated" do
      before { subject.generate! }

      it "writes the JSON string of the report into the S3 metrics bucket" do
        subject.publish!

        expect(@s3_client_double)
          .to have_received(:put_object).with(
            bucket: "stub-bucket",
            key: :some_key,
            body: :payload,
          )
      end
    end
  end
end
