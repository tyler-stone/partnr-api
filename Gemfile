source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.4'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

# use the pgsql database
gem 'pg'

# testing gems
group :test, :development do
  gem 'rspec'
  gem 'rspec-rails'
  gem 'factory_girl_rails', "~> 4.0"
  gem 'simplecov'
  gem 'json-schema-rspec'
  gem 'byebug'
end

# use devise for authentication
gem 'devise'

# use foreman for the dev server logger
gem 'foreman'

# use puma as the http server
gem 'puma'

# use kaminari to paginate the models
gem 'kaminari'

# gems for API building and documentation
gem 'grape', '~> 0.12.0'
gem 'grape-entity', '~> 0.4.8'
gem 'grape-swagger', '~> 0.9.0' # before upgrading this one, test it thoroughly, versions 0.8 and 0.10 both currently have bugs
gem 'grape-swagger-rails', '~> 0.1.0'

# allow Grape to handle the security instead of strong_params
gem 'hashie-forbidden_attributes'

# let's do some location things
gem 'geokit-rails'

# public activity for the activity feed
gem 'public_activity'

# upload images
gem "paperclip", "~> 5.0.0.beta1"
gem 'aws-sdk'

# watch service performance
gem 'newrelic_rpm'

# we want to allow CORS
gem 'rack-cors', :require => 'rack/cors'

ruby '2.3.0'
