task :sync_s3_volumetrics do
  PerformancePlatform::UseCase::SyncS3ToElasticSearch.new(
   elastic_search_gateway: PerformancePlatform::Gateway::ElasticSearch.new,
   s3_gateway: PerformancePlatform::Gateway::S3.new
  ).execute
end
