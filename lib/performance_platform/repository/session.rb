class PerformancePlatform::Repository::Session < Sequel::Model(:sessions)
  dataset_module do
    def account_usage_stats(*)
      DB.fetch("
        SELECT
          count(distinct(username)) as total,
          count(distinct(concat_ws('-', sessions.username, ip_locations.location_id))) as per_site
        FROM
          sessions
          LEFT JOIN
            ip_locations
            ON
            (ip_locations.ip = sessions.siteIP)
        WHERE
          date(sessions.start) = '#{Date.today - 1}'
        GROUP BY
            date(start)").first
    end

    def unique_users_stats(period:)
      sql = "SELECT sum(users)/count(*) DIV 1 as `count`
      FROM (SELECT date(start) AS day, count(distinct(username)) AS users
      FROM sessions WHERE start BETWEEN date_sub('#{Date.today}', INTERVAL 1 #{period})
      AND '#{Date.today}' AND dayofweek(start) NOT IN (1,7) GROUP BY day) foo;"

      DB.fetch(sql).first
    end
  end
end
