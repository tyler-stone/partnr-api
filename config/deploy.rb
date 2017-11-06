# skip migration if files in db/migrate were not modified
set :conditionally_migrate, true

# If you use Rails 4+ and you'd like to clean up old assets after each deploy,
# set this to the number of versions to keep
set :keep_assets, 2
