require 'aws-sdk-s3'

class PerformancePlatform::Gateway::S3IpLocations
  def initialize
    @s3 = Aws::S3::Client.new(config)
  end

  def fetch
    bucket = ENV.fetch('S3_PUBLISHED_LOCATIONS_IPS_BUCKET')
    key = ENV.fetch('S3_PUBLISHED_LOCATIONS_IPS_OBJECT_KEY')

    resp = s3.get_object(bucket: bucket, key: key)
    resp.body.read
  end

private

    DEFAULT_REGION = 'eu-west-2'.freeze

    def config
      {
        region: DEFAULT_REGION,
        access_key_id: 'ACCESS_KEY_ID',
        secret_access_key: 'SECRET_ACCESS_KEY'
      }
    end

  attr_reader :s3
end
