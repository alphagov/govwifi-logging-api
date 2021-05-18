task :sync_s3_volumetrics do
  Performance::UseCase::SyncS3ToElasticsearch.new(
    elasticsearch_gateway: Performance::Gateway::Elasticsearch.new("volumetrics"),
    s3_gateway: Performance::Gateway::S3.new("volumetrics"),
  ).execute

  Performance::UseCase::SyncS3ToElasticsearch.new(
    elasticsearch_gateway: Performance::Gateway::Elasticsearch.new("active_users"),
    s3_gateway: Performance::Gateway::S3.new("active-users"),
  ).execute

  Performance::UseCase::SyncS3ToElasticsearch.new(
    elasticsearch_gateway: Performance::Gateway::Elasticsearch.new("roaming_users"),
    s3_gateway: Performance::Gateway::S3.new("roaming-users"),
  ).execute

  Performance::UseCase::SyncS3ToElasticsearch.new(
    elasticsearch_gateway: Performance::Gateway::Elasticsearch.new("completion_rate"),
    s3_gateway: Performance::Gateway::S3.new("completion_rate"),
  ).execute
end
