class Services
  def self.s3_client
    Aws::S3::Client.new(region: "eu-west-2")
  end

  def self.elasticsearch_client
    Elasticsearch::Client.new host: ENV["VOLUMETRICS_ENDPOINT"]
  end
end
