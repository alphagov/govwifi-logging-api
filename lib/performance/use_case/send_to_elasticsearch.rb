class Performance::UseCase::SendToElasticsearch
  def initialize(
    elasticsearch_gateway: Performance::Gateway::Elasticsearch.new("volumetrics"),
    logger: Logger.new(STDOUT),
    data_fetcher: Performance::UseCase::FetchVolumetricsData
  )
    @elasticsearch_gateway = elasticsearch_gateway
    @logger = logger
    @data_fetcher = data_fetcher.new
  end

  def execute
    data = @data_fetcher.fetch
    @elasticsearch_gateway.write data
    @logger.info "Wrote volumetrics data point '#{data}' to Elasticsearch"
  end
end
