Sequel.migration do
  change do
    create_table(:tasks) do
      primary_key :id
      Date :date
      String :theme
      end
  end
end