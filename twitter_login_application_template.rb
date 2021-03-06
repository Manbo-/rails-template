# gems
# ==================================================
run "echo Added gem file"

gem_group :development do
  gem "rspec-rails"
  gem "rails-erd"
end

gem_group :test do
  gem 'simplecov', :require => false
  gem 'simplecov-rcov', :require => false
end

# Install spec_helper.rb
# ==================================================
run "./bin/rails g rspec:install"
run "rm -rf test"

gem 'settingslogic'

if yes?("Whould you like to use carrierwave ?")
  gem 'carrierwave'
  gem 'rmagick', :require => false
end

if yes?('Would you like to use cron?')
  gem 'whenever'
  run "bundle exec wheneverize"
end

if yes?("This app will be following up on both the smartphone and PC?")
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

# SNS config
# ==================================================
  gem 'twitter'
  gem 'oauth'

  run "cat << EOF >> config/sns.yml.sample
production:
  twitter:
    consumer_key: <CONSUMER KEY>
    consumer_secret: <CONSUMER SECRET>>
    oauth_site_url: https://twitter.com
development:
  twitter:
    consumer_key: <CONSUMER KEY>
    consumer_secret: <CONSUMER SECRET>>
    oauth_site_url: https://twitter.com
test:
  twitter:
    consumer_key: <CONSUMER KEY>
    consumer_secret: <CONSUMER SECRET>>
    oauth_site_url: https://twitter.com
EOF"
  run "cp config/sns.yml.sample config/sns.yml"
  # Added settings for twitter
  # ==================================================
  run "cat << EOF >> config/initializers/twitter.rb
module Twitter
  CONFIG = YAML.load_file(Rails.root.to_s + \"/config/sns.yml\")[Rails.env]['twitter']
  CONSUMER_KEY    = CONFIG['consumer_key']
  CONSUMER_SECRET = CONFIG['consumer_secret']
  OAUTH_SITE_URL  = CONFIG['oauth_site_url']
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


if yes?('Do you want to upload to Amazon S3 in the file?')
  gem 'fog'

  # Setting carrierwave using fog
  # ==================================================
  run "echo Set carrierwave config"

  run "cat << EOF >> config/initializers/carrierwave.rb
if Rails.env.production? || Rails.env.staging?
  CONFIG = YAML.load_file(Rails.root.to_s + \"/config/aws.yml\")[Rails.env]
  CarrierWave.configure do |config|
    config.storage = :fog
    config.fog_credentials = {
      :provider              => 'AWS',
      :aws_access_key_id     => CONFIG[\"access_key\"],
      :aws_secret_access_key => CONFIG[\"secret_access_key\"],
      :region                => CONFIG[\"region\"],
    }
    config.fog_directory = CONFIG[\"bucket\"]
    config.asset_host    = CONFIG[\"host\"]
  end
else
  CarrierWave.configure do |config|
    config.storage = :file
    config.asset_host = Settings.host
  end
end
EOF"

  run "cat << EOF >> config/aws.yml
test:
  access_key: < ACCESS_KEY >
  secret_access_key: < SECRET ACCESS KEY >
  bucket: < BUCKET >
  region: < REGION >
  host: < HOST >
development:
  access_key: < ACCESS_KEY >
  secret_access_key: < SECRET ACCESS KEY >
  bucket: < BUCKET >
  region: < REGION >
  host: < HOST >
production:
  access_key: < ACCESS_KEY >
  secret_access_key: < SECRET ACCESS KEY >
  bucket: < BUCKET >
  region: < REGION >
  host: < HOST >
EOF"

end
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
config/sns.yml
EOF"

# bundle install
# ==================================================
run "./bin/bundle install"

# First Commit
# ==================================================

git :init
git add: "."
git commit: %Q{ -m 'first commit' }
