# encoding: UTF-8
# -*- mode: ruby -*-
# vi: set ft=ruby :

source 'https://rubygems.org'

chef_version = ENV.key?('CHEF_VERSION') ? ENV['CHEF_VERSION'] : nil

# travis ci does not yet support ruby >= 2.2.2
gem 'activesupport', '~> 4.2'
gem 'fauxhai',       '= 3.9'
gem 'nio4r',         '~> 1.2'
gem 'rack',          '~> 1.6'

group :test do
  gem 'berkshelf',  '~> 4.1'
  gem 'chefspec'
  gem 'rake'
  gem 'rspec',      '~> 3.4'
end

group :style do
  gem 'foodcritic', '~> 6.0'
  gem 'rubocop',    '~> 0.37'
end

group :unit do
  gem 'chef', chef_version unless chef_version.nil? # Ruby 1.9.3 support
end

group :integration do
  gem 'kitchen-vagrant', '~> 0.20'
  gem 'test-kitchen',    '~> 1.4'
  gem 'vagrant-wrapper', '~> 2.0'
end

group :integration, :integration_cloud do
  gem 'kitchen-digitalocean', '~> 0.8'
  gem 'kitchen-ec2',          '~> 0.9'
  gem 'serverspec',           '~> 2.0'
end
