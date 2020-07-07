class PerformancePlatform::Repository::Session < Sequel::Model(:sessions)
  dataset_module do
    def active_users_stats(period:, date:)
      DB.fetch("
        SELECT
          count(distinct(username)) as total
        FROM sessions WHERE start BETWEEN date_sub('#{date - 1}', INTERVAL 1 #{period}) AND '#{date - 1}'
          AND sessions.success = 1").first
    end

    def roaming_users_count(period:, date:)
      sql = "SELECT COUNT(*) as total_roaming FROM (
              SELECT
                username, count(distinct(location_id)) as roam_count
              FROM
                sessions s
              INNER JOIN
                ip_locations il on s.siteIP = il.ip
              WHERE
                s.success = 1
              AND
                start BETWEEN date_sub('#{date}', INTERVAL 1 #{period}) AND '#{date}'
              GROUP BY
                username
              HAVING
                roam_count > 1)
             as roaming_count"

      DB.fetch(sql).first
    end

    def unique_users_stats(period:, date:)
      sql = "SELECT sum(users)/count(*) DIV 1 as `count`
      FROM (SELECT date(start) AS day, count(distinct(username)) AS users
      FROM sessions WHERE start BETWEEN date_sub('#{date}', INTERVAL 1 #{period})
      AND '#{date}' AND dayofweek(start) NOT IN (1,7) GROUP BY day) foo;"

      DB.fetch(sql).first
    end
  end
end
