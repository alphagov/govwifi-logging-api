task :publish_metrics_to_elasticsearch do
  Performance::UseCase::SendToElasticsearch.new.execute
end
