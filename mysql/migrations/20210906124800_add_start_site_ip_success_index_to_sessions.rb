Sequel.migration do
  change do
    alter_table :sessions do
      add_index %i[start siteIP success], name: "start_siteIP_successs"
    end
  end
end
