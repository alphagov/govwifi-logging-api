class PerformancePlatform::Repository::Session < Sequel::Model(:sessions)
  dataset_module do
    def active_users_stats(period:, date:)
      DB.fetch("
        SELECT
          count(distinct(username)) as total
        FROM sessions WHERE start BETWEEN date_sub('#{date - 1}', INTERVAL 1 #{period}) AND '#{date - 1}'
          AND sessions.success = 1").first
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
