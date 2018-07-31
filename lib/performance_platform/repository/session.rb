class PerformancePlatform::Repository::Session < Sequel::Model(:sessions)
  dataset_module do
    def stats
      DB.fetch("
      SELECT
      count(distinct(username)) as total,
      count(distinct(concat_ws('-', sessions.username, site.address))) as per_site
      FROM sessions
      LEFT JOIN siteip
      ON (siteip.ip = sessions.siteIP)
      LEFT JOIN site
      ON (siteip.site_id = site.id)
      WHERE site.org_id IS NOT NULL
      AND date(sessions.start) = '#{Date.today - 1}'
      GROUP BY date(start)").first
    end

    def unique_users_stats(period:)
      sql = "SELECT count(distinct(username)) as `count`
        FROM sessions
        WHERE start
          BETWEEN date_sub('#{Date.today}', INTERVAL 1 #{period.to_s.upcase})
          AND '#{Date.today}'
        AND dayofweek(start) NOT IN (1,7)"

      DB.fetch(sql).first
    end
  end
end
