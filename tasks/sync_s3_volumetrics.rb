task sync_s3_volumetrics: :load_env do
  bucket = ENV.fetch("S3_METRICS_BUCKET")

  %w[volumetrics active_users roaming_users completion_rate].map do |metric|
    Performance::UseCase::SyncS3ToElasticsearch.new(
      elasticsearch_gateway: Performance::Gateway::Elasticsearch.new(Performance::Metrics::ELASTICSEARCH_INDEX),
      s3_gateway: Performance::Gateway::S3.new(metric, bucket),
    ).execute
  end
end
