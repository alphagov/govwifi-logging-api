class PerformancePlatform::Gateway::SequelIPLocations
  def save(ip_locations)
    truncate_ip_locations
  end

private

  def truncate_ip_locations
    DB[:ip_locations].truncate
  end
end
