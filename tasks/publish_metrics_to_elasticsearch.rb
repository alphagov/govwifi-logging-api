task :publish_metrics_to_elasticsearch do
  Volumetrics::UseCase::SendToElasticsearch.new.execute
end
