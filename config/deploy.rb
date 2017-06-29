require 'bundler/capistrano'

load 'deploy/assets'

set :application, 'eopas'
set :repository,  'git://github.com/eopas/eopas'
set :scm, :git

role :web, 'eopas-qa.intersect.org.au'
role :app, 'eopas-qa.intersect.org.au'
role :db,  'eopas-qa.intersect.org.au', :primary => true # This is where Rails migrations will run

set :deploy_to, "/srv/www/#{application}"
set :user, 'deploy'
set :use_sudo, false
set :deploy_via, :remote_cache
set :keep_releases, 5

set :default_environment, {'PATH' => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"}

set :linked_dirs, fetch(:linked_dirs, []).push('bin', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'assets', 'XSLT', 'SCHEMAS')

# database
namespace :deploy do
  desc "Symlink shared configs and folders on each release."
  task :symlink_shared do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
end
after 'deploy:assets:symlink', 'deploy:symlink_shared'

# Unicorn
require 'capistrano-unicorn'
after 'deploy:restart', 'unicorn:restart'  # app preloaded

# Delayed job
require 'delayed/recipes'
after "deploy:stop",    "delayed_job:stop"
after "deploy:start",   "delayed_job:start"
after "deploy:restart", "delayed_job:restart"

namespace :delayed_job do
 desc "Stop the delayed_job process"
 task :stop, :roles => :app do
   run "cd #{current_path} && RAILS_ENV=production script/delayed_job stop"
 end
 desc "Start the delayed_job process"
 task :start, :roles => :app do
   run "cd #{current_path} && RAILS_ENV=production script/delayed_job start"
 end
 desc "Restart the delayed_job process"
 task :restart, :roles => :app do
   stop
   start
 end
end
