class PerformancePlatform::Gateway::SequelIPLocations
  def save(ip_locations)
    truncate_ip_locations

    ip_locations.each do |loc|
      DB[:ip_locations].insert(ip: loc[:ip], location_id: loc[:location_ip])
    end
  end

private

  def truncate_ip_locations
    DB[:ip_locations].truncate
  end
end
