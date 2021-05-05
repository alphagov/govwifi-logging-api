task :sync_s3_volumetrics do
  Performance::UseCase::SyncS3ToElasticsearch.new(
    elasticsearch_gateway: Performance::Gateway::Elasticsearch.new,
    s3_gateway: Performance::Gateway::S3.new,
  ).execute
end

