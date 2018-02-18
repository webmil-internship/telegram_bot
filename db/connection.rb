DB = Sequel.connect(ENV['DB_CONNECTION'])
Sequel::Model.raise_on_save_failure = false
