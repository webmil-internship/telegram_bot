Sequel.migration do
  change do
    create_table(:ratings) do
      primary_key :id
      String :user_id
      Date :date
      String :theme
      BigDecimal :confidence
    end
  end
end