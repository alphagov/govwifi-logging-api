class PerformancePlatform::Repository::Session < Sequel::Model(:sessions)
  # rubocop:disable Metrics/BlockLength
  dataset_module do
    def stats
      result = DB.fetch("SELECT
        count(distinct(username)) as total,
        count(distinct(concat_ws('-', sessions.username, site.address))) as per_site
        FROM sessions
          LEFT JOIN siteip
          ON (siteip.ip = sessions.siteIP)
          LEFT JOIN site
          ON (siteip.site_id = site.id)
        WHERE site.org_id IS NOT NULL
        AND start
          BETWEEN date_sub('#{Date.today - 1}', INTERVAL 1 WEEK)
          AND '#{Date.today - 1}'
        GROUP BY date(start);").all

      {
        total: result.sum { |a| a[:total] },
        per_site: result.sum { |a| a[:per_site] },
      }
    end

    def unique_users_stats(period:)
      sql = "
      SELECT start AS day, count(distinct(username)) AS users FROM sessions
      WHERE start BETWEEN date_sub('#{Date.today}', INTERVAL 1 #{period.to_s.upcase})
      AND '#{Date.today}'
      AND dayofweek(start) NOT IN (1,7)
      GROUP BY day"

      result = DB.fetch(sql).all.sum { |r| r[:users].to_i }

      { count: result }
    end
  end
  # rubocop:enable Metrics/BlockLength
end
