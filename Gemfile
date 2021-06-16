# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.6.0'
gem 'rails', '~> 5.2'

gem 'activerecord-postgis-adapter', '~> 5.2.2'
# use my fork to fix using left join intead of join on search
gem 'administrate', '~>0.13.0', git: 'https://github.com/wykhuh/administrate.git'
gem 'administrate-field-image'
gem 'administrate-field-json', git: 'https://github.com/eddietejeda/administrate-field-json.git'
gem 'administrate-field-nested_has_many', '~> 1.0.0'
gem 'autoprefixer-rails', '~> 7.2'
gem 'aws-sdk-s3', '~> 1.14.0', require: false
gem 'bootsnap', '~> 1.3.0'
gem 'bootstrap-sass', '~> 3.3.7'
gem 'bundler', '~> 1.17.2'
gem 'devise', '~> 4.3'
gem 'devise_invitable', '~> 1.7.4'
gem 'fast_jsonapi', '~> 1.6.0', git: 'https://github.com/fast-jsonapi/fast_jsonapi'
gem 'fastimage', '~> 2.1.1'
gem 'flutie', '~> 2.0'
gem 'httparty', '~> 0.15.6'
# gem 'jemalloc', '~> 1.0.1'
gem 'jquery-rails', '~> 4.3.3' # required by bootstrap-sass
gem 'kaminari', '~> 1.1.1'
gem 'lograge', '~> 0.10.0'
gem 'mail_form', '~> 1.8.0'
gem 'mimemagic', '~> 0.3.7'
gem 'mini_magick', '~> 4.10.1' # resize ActiveStorage images
gem 'pg', '~> 0.21'
gem 'pg_query', '>= 0.9.0'
gem 'pg_search', '~> 2.1.2'
gem 'pghero', '~> 2.6.0'
gem 'photoswipe-rails', '~> 4.1', '>= 4.1.2'
gem 'puma', '~> 4.3'
gem 'pundit', '~> 1.1.0'
gem 'rack-canonical-host', '~> 0.2'
gem 'rgeo', '~> 2.1.1'
gem 'rgeo-geojson', '~> 2.1.1'
gem 'rgeo-shapefile', '~> 2.0.1'
gem 'sass-rails', '~> 5.0' # required by bootstrap-sass
gem 'sidekiq', '~> 5.0'
gem 'simple_enum', '~> 2.3'
gem 'simple_form', '~> 4.0.1'
gem 'sparql', '~> 3.1', '>= 3.1.2'
gem 'sparql-client', '~> 3.1'
gem 'summernote-rails', '~> 0.8.10.0'
gem 'title', '~> 0.0.7'
gem 'uglifier', '~> 4.0'
gem 'unicode-display_width', '~> 1.7'
gem 'webpacker', '~> 3.5.3'

group :development do
  gem 'better_errors', '~> 2.4'
  gem 'binding_of_caller', '~> 0.7'
  gem 'bullet', '~> 6.1.0'
  gem 'derailed_benchmarks', '~> 1.7.0'
  gem 'i18n-tasks', '~> 0.9'
  gem 'letter_opener', '~> 1.4.1'
  gem 'rack-mini-profiler', '~> 2.0.3'
  gem 'spring', '~> 2.0'
  gem 'spring-commands-rspec', '~> 1.0'
  gem 'stairs', '~> 0.10'
end

group :development, :test, :staging do
  gem 'factory_bot_rails', '~> 4.8.2'
  gem 'faker', '~> 1.8.7'
end

group :development, :test do
  gem 'bundler-audit', '~> 0.7', require: false
  gem 'dotenv-rails', '~> 2.4.0'
  gem 'listen', '~> 3.1'
  gem 'pry-byebug', '~> 3.5'
  gem 'pry-rails', '~> 0.3'
  gem 'rspec-rails', '~> 4.0', '>= 4.0.1'
  gem 'rubocop', '~> 0.52'
  gem 'vcr', '~> 4.0.0'
  gem 'webmock', '~> 3.4.1'
end

group :production, :staging do
  gem 'connection_pool', '~> 2.2.1'
  gem 'dalli', '~> 2.7.10'
  gem 'rack-cors', '~> 1.1.1'
  gem 'scout_apm', '~> 2.4.13'
  gem 'sendgrid-ruby', '~> 5.2.0'
  gem 'sentry-raven', '~> 2.7.4'
end

group :test do
  gem 'capybara', '~> 3.33.0'
  gem 'database_cleaner', '~> 1.6'
  gem 'launchy', '~> 2.4'
  gem 'rails-controller-testing', '~> 1.0.2'
  gem 'rspec-sidekiq', '~> 3.1'
  gem 'rspec-support', '~> 3.9'
  gem 'shoulda-matchers', '~> 3.1', '>= 3.1.3'
  gem 'timecop', '~> 0.9'
end

# gem 'river', path: 'river'
