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
  end
end
