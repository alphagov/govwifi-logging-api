require "logger"

class Volumetrics::UseCase::SyncS3ToElasticsearch
  def initialize(s3_gateway:, elasticsearch_gateway:, logger: Logger.new(STDOUT))
    @s3_gateway = s3_gateway
    @elasticsearch_gateway = elasticsearch_gateway
    @logger = logger
  end

  def execute
    record_count = 0

    @s3_gateway.each do |record|
      @elasticsearch_gateway.write(record[:key], record[:data])
      record_count += 1
    end

    @logger.info "Writing #{record_count} records from S3 to ElasticSearch"
  end
end
