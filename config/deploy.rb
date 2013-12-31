set :application, 'Hawkeye'
set :repo_url, 'https://tylersam@github.com/tylersam/hawkeye.git'

# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# set :deploy_to, '/var/www/my_app'
set :scm, :git
set :deploy_to, "/home/tylersam/webapps/hawkeye"

# set :format, :pretty
# set :log_level, :debug
# set :pty, true

# set :linked_files, %w{config/database.yml}
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :keep_releases, 5

namespace :deploy do

  desc 'Restart nginx'
  task :restart do
    run "#{deploy_to}/bin/restart"
  end

end
