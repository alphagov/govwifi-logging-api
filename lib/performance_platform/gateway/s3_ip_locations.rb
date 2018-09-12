require 'aws-sdk-s3'

class PerformancePlatform::Gateway::S3IpLocations
  def initialize
    @s3 = Aws::S3::Client.new(config)
  end

  def fetch
    resp = s3.get_object(bucket: 'bucket-name', key: 'object-key')
    resp.body.read
  end

private

    DEFAULT_REGION = 'eu-west-2'.freeze

    def config
      { region: DEFAULT_REGION }
    end

  attr_reader :s3
end
