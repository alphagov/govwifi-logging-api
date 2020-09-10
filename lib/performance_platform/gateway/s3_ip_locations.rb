require "aws-sdk-s3"

class PerformancePlatform::Gateway::S3IpLocations
  def fetch
    bucket = ENV.fetch("S3_PUBLISHED_LOCATIONS_IPS_BUCKET")
    key = ENV.fetch("S3_PUBLISHED_LOCATIONS_IPS_OBJECT_KEY")

    response = Services.s3_client.get_object(bucket: bucket, key: key)
    JSON.parse(response.body.read)
  end
end
