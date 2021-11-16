module Performance::Metrics
  class ProductPageMetricSender

    def send_data(product_page_s3_bucket)
      Services.s3_client.put_object(
        bucket: product_page_s3_bucket,
        key: "performance_metrics",
        body: stats.to_json.to_s,
      )
    end

  private

    def repository
      Performance::Repository::Session
    end

    def stats
      {
        registered_users: repository.active_users_stats,
        users_last_week: repository.active_users_stats(period: 'week', date: Date.today),
        users_last_month: repository.active_users_stats(period: 'month', date: Date.today),
      }
    end
  end
end
