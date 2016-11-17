source "https://rubygems.org"

gem "sinatra"
gem "capistrano"
gem "httparty"
gem "aws-sdk", "~> 2"
gem "dotenv"
gem "cityhash"

group :production do
  gem 'unicorn', :platforms => :ruby
  gem 'capistrano-rbenv'
  gem 'capistrano3-unicorn', :require => false
  gem 'capistrano-bundler'
end
