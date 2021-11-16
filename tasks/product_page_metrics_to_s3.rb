require "logger"

task :product_page_metrics_to_s3, %i[product_page_s3_bucket] => :load_env do |_, args|
  Performance::Metrics::ProductPageMetricSender.new.send_data(args[:product_page_s3_bucket])
end
