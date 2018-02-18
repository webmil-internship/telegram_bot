

namespace :db do
  desc 'Run migrations'
  task :migrate, [:version] do |t, args|
    require 'sequel'
    Sequel.extension :migration
    db = Sequel.connect('sqlite://db/mainbase.db')
    puts 'Migrating to latest'
    Sequel::Migrator.run(db, 'db/migrations')
  end
end
