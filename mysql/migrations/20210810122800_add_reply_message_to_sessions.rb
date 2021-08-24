Sequel.migration do
  change do
    alter_table :sessions do
      add_column :authentication_reply, String, default: ""
    end
  end
end
