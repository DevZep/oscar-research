# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

set :application, 'oscar-research'
set :repo_url, "git@github.com:rotati/#{fetch(:application)}.git"
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :deploy_to, "/var/www/#{fetch(:application)}"

set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets')
set :linked_files, fetch(:linked_files, []).push('.env')

set :pty, false

set :keep_releases, 5

namespace :deploy do

  task :cleanup_assets do
    on roles :all do
      execute "cd #{release_path}/ && ~/.rvm/bin/rvm default do bundle exec rake assets:clobber RAILS_ENV=#{fetch(:stage)}"
    end
  end

  before :updated, :cleanup_assets
end

set :passenger_restart_with_touch, true

set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

require 'appsignal/capistrano'
