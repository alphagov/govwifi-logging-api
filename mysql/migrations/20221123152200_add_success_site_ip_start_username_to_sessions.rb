Sequel.migration do
  change do
    alter_table :sessions do
      add_index %i[success siteIP start username], name: "success_siteIP_start_username"
    end
  end
end
