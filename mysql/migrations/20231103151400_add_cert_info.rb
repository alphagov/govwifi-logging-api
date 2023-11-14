Sequel.migration do
  change do
    alter_table :sessions do
      add_column :cert_serial, String, default: ""
      add_column :cert_issuer, String, default: ""
      add_column :cert_subject, String, default: ""
    end
  end
end
