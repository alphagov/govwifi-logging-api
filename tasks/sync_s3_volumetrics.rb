task :sync_s3_volumetrics do
  Performance::UseCase::SyncS3ToElasticsearch.new(
    elasticsearch_gateway: Performance::Gateway::Elasticsearch.new(Performance::Metrics::ELASTICSEARCH_INDEX),
    s3_gateway: Performance::Gateway::S3.new("volumetrics"),
  ).execute

  Performance::UseCase::SyncS3ToElasticsearch.new(
    elasticsearch_gateway: Performance::Gateway::Elasticsearch.new(Performance::Metrics::ELASTICSEARCH_INDEX),
    s3_gateway: Performance::Gateway::S3.new("active_users"),
  ).execute

  Performance::UseCase::SyncS3ToElasticsearch.new(
    elasticsearch_gateway: Performance::Gateway::Elasticsearch.new(Performance::Metrics::ELASTICSEARCH_INDEX),
    s3_gateway: Performance::Gateway::S3.new("roaming_users"),
  ).execute

  Performance::UseCase::SyncS3ToElasticsearch.new(
    elasticsearch_gateway: Performance::Gateway::Elasticsearch.new(Performance::Metrics::ELASTICSEARCH_INDEX),
    s3_gateway: Performance::Gateway::S3.new("completion_rate"),
  ).execute
end
