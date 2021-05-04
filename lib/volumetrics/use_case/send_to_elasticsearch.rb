class Volumetrics::UseCase::SendToElasticsearch
  def initialize(
    elasticsearch_gateway: Volumetrics::Gateway::Elasticsearch,
    logger: Logger.new(STDOUT),
    data_fetcher: Volumetrics::UseCase::FetchData
  )
    @elasticsearch_gateway = elasticsearch_gateway
    @logger = logger
    @data_fetcher = data_fetcher.new
  end

  def execute
    data = @data_fetcher.fetch
    @elasticsearch_gateway.new.write data
    @logger.info "Wrote volumetrics data point '#{data}' to Elasticsearch"
  end
end
