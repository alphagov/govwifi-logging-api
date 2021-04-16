require "logger"

class Volumetrics::UseCase::SyncS3ToElasticsearch
  def initialize(s3_gateway:, elasticsearch_gateway:, logger: Logger.new(STDOUT))
    @s3_gateway = s3_gateway
    @elasticsearch_gateway = elasticsearch_gateway
    @logger = logger
  end

  def execute
    records = @s3_gateway.fetch

    @logger.info "Writing #{records.count} records from S3 to ElasticSearch"

    records.each do |record|
      @elasticsearch_gateway.write(record[:filename], record[:data])
    end
  end
end
