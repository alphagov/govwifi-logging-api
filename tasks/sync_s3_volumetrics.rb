task :sync_s3_volumetrics do
  Volumetrics::UseCase::SyncS3ToElasticsearch.new(
    elasticsearch_gateway: Volumetrics::Gateway::Elasticsearch.new,
    s3_gateway: Volumetrics::Gateway::S3.new,
  ).execute
end
