# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

group :development do
  gem 'codebreaker', git: 'https://github.com/DaniilYusha/codebreaker', branch: 'development'
  gem 'rack', '~> 2.2', '>= 2.2.3'
  gem 'fasterer', '~> 0.8.3'
  gem 'i18n', '~> 1.8', '>= 1.8.5'
  gem 'rubocop', '~> 0.89.1'
  gem 'rubocop-rspec', '~> 1.42'
end

group :test do
  gem 'rspec', '~> 3.9'
  gem 'simplecov', '~> 0.18.5'
end
