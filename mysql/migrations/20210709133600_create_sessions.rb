Sequel.migration do
  change do
    create_table?(:sessions) do
      primary_key :id, type: :Bignum, size: 20
      Timestamp :start, null: true, default: nil
      Timestamp :stop, null: true, default: nil
      String :siteIP, size: 15, default: nil, fixed: true
      String :username, size: 6, default: nil, fixed: true
      String :cert_name, size: 64, default: nil
      String :mac, size: 17, default: nil, fixed: true
      String :ap, size: 17, default: nil, fixed: true
      String :building_identifier, size: 20, default: nil
      TrueClass :success, default: true
      index :username, name: "sessions_username"
      index %i[siteIP username], name: "siteIP"
      index %i[start username], name: "sessions_start_username"
    end
  end
end
