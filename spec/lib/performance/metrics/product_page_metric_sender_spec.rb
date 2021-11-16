# frozen_string_literal: true

require_relative "./s3_fake_client"

describe Performance::Metrics::ProductPageMetricSender do
  let(:today) { Date.today }
  let(:s3_client) { Performance::Metrics.fake_s3_client }


  def s3_contents(key)
    contents = s3_client.get_object(bucket: "stub-bucket",
                                    key: key)
    JSON.parse(contents.body.read)
  end

  before do
    DB[:sessions].truncate
    USER_DB[:userdetails].truncate
    allow(Services).to receive(:s3_client).and_return s3_client
    FactoryBot.create_list(:sessions, 7, start: Date.today - 5*7)
    FactoryBot.create_list(:sessions, 5, start: Date.today - 3*7)
    FactoryBot.create_list(:sessions, 3, start: Date.today - 2)
    FactoryBot.create_list(:sessions, 1, success: 0)
    Performance::Metrics::ProductPageMetricSender.new.send_data("stub-bucket")
  end

  it 'Writes the number of registered users that have logged in to S3' do
    expect(s3_contents("performance_metrics")).to include({"registered_users" => 15})
  end

  it 'Writes the number of users that have logged in in the last week to S3' do
    expect(s3_contents("performance_metrics")).to include({"users_last_week" => 3})
  end

  it 'Writes the number of users that have logged in in the month week to S3' do
    expect(s3_contents("performance_metrics")).to include({"users_last_month" => 8})
  end

end
