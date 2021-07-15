Sequel.migration do
  change do
    create_table?(:ip_locations) do
      String :ip, size: 30, default: nil
      Integer :location_id, size: 11
    end
  end
end
