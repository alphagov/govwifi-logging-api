require "aws-sdk-s3"

class PerformancePlatform::Gateway::S3IpLocations
  def initialize
    @s3 = Aws::S3::Client.new(region: "eu-west-2")
  end

  def fetch
    bucket = ENV.fetch("S3_PUBLISHED_LOCATIONS_IPS_BUCKET")
    key = ENV.fetch("S3_PUBLISHED_LOCATIONS_IPS_OBJECT_KEY")

    response = s3.get_object(bucket: bucket, key: key)
    JSON.parse(response.body.read)
  end

private

  attr_reader :s3
end
