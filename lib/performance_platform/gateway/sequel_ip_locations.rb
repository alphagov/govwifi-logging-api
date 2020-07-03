class PerformancePlatform::Gateway::SequelIPLocations
  def save(ip_locations)
    truncate_ip_locations

    data = ip_locations.map do |ip_location|
      [ip_location["ip"], ip_location["location_id"]]
    end

    DB[:ip_locations].import(%i[ip location_id], data)
  end

private

  def truncate_ip_locations
    DB[:ip_locations].truncate
  end
end
