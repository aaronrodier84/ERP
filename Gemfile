source 'https://rubygems.org'
ruby '2.3.1'

gem 'rails', '4.2.6'
gem 'pg'
gem 'devise'
gem 'haml'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'sidekiq'
gem 'therubyracer', platforms: :ruby
gem 'sinatra', :require => nil
gem 'peddler'  # Amazon MWS API in Ruby 
gem 'pdf-writer'
gem 'prawn'  # PDF Writer
gem 'barby'  # Barcode generator 
gem 'carrierwave'
gem 'cloudinary'
gem 'chunky_png'
gem 'aws-sdk', '~> 2'
gem 'bootstrap_form'  # https://github.com/bootstrap-ruby/rails-bootstrap-forms
gem 'wkhtmltopdf-binary'
gem 'wicked_pdf'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jquery-turbolinks'

# bulk create activerecord models
gem 'activerecord-import'

# memcache integration
gem 'dalli'

# validations made right
gem 'dry-validation'

gem "highcharts-rails"

# better logging
gem 'awesome_print'
gem 'rails_semantic_logger'

group :production do
  gem 'rails_12factor'

  # heroku memcachier addon configuration
  gem 'memcachier'
end

group :development, :test do
  gem 'pry-nav'
  gem 'dotenv-rails'

  gem 'factory_girl_rails'
  gem 'minitest-spec-rails'
  gem 'minitest-reporters'
  gem 'mocha'

  gem 'database_cleaner'
  gem 'annotate'  # schema info in model/factory files

  gem 'bullet'
end

group :development do
  gem 'quiet_assets'
  #gem 'web-console', '~> 2.0'
  #gem 'spring'

  gem 'guard'
  gem 'guard-minitest'
  gem 'guard-ctags-bundler'
  gem 'ripper-tags'
  gem "better_errors"     # better error pages with a debug console
  gem "binding_of_caller" # better_errors dependency
  gem 'httplog'

  # codestyle & code quality validation
  gem 'flay', '= 2.7.0'
  gem 'pronto'
  gem 'pronto-rubocop', require: false
  gem 'pronto-reek', require: false
  gem 'pronto-flay', require: false
  gem 'pronto-brakeman', require: false
  gem 'pronto-coffeelint', require: false
end

group :test do
  gem 'timecop'
  gem 'simplecov', require: false
end

group :test do
  gem 'capybara'
  gem 'poltergeist'
  gem 'launchy'
  gem 'capybara-screenshot'
end
