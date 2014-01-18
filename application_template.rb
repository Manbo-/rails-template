# gems
# ==================================================
run "echo Added gem file"

gem "thin"
gem 'newrelic_rpm'

gem_group :development, :test do
  gem "pry-rails"
  gem "rspec-rails"
  gem 'factory_girl_rails'
end

gem_group :test do
  gem 'database_cleaner'
end

# Install spec_helper.rb
# ==================================================
run "./bin/rails g rspec:install"
run "rm -rf test"

gem 'haml-rails'
gem "compass-rails"

gem 'rainbow'
gem 'settingslogic'
gem 'google-analytics-rails'
gem 'kaminari'
gem 'draper'

if yes?("use jpmobile?")
  gem 'jpmobile'
end

# Setup settingslogic config
# ==================================================
run "cat << EOF >> config/settings.yml
defaults: &defaults

development:
  <<: *defaults
  host: localhost:3000

test:
  <<: *defaults

production:
  <<: *defaults
EOF"

run "cat << EOF >> config/initializers/0_settings.rb
class Settings < Settingslogic
  source \"\#{Rails.root\}/config/settings.yml\"
  namespace Rails.env
end
EOF"

# DB config
# ==================================================
run "cp config/database.yml config/database.yml.sample"

# Seeting seed
# ==================================================
run "ehco db/seeds.rb"

run "mkdir -p db/seeds/production"
run "mkdir -p db/seeds/development"
run "mkdir -p db/seeds/test"

run "cat << EOF > db/seeds.rb
table_names = %w()

table_names.each do |table_name|
  p table_name
  path = \"\#{Rails.root\}/db/seeds/\#{Rails.env\}/\#{table_name\}.rb\"
  require(path) if File.exist?(path)
end
EOF"

# Set .gitignore
# ==================================================
run "ehco Set .gitignore"
run "cat << EOF >> .gitignore
config/database.yml
db/schema.rb
vendor/bundle
tmp
coverage
config/database.yml
EOF"

# bundle install
# ==================================================
run "./bin/bundle install"

# First Commit
# ==================================================

git :init
git add: "."
git commit: %Q{ -m 'first commit' }
