Sequel.migration do
  change do
    alter_table :sessions do
      add_column :task_id, String, default: "", size: 100
    end
  end
end
