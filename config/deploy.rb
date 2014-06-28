set :application, "hawkeye"
set :repository,  "https://tylersam@github.com/tylersam/hawkeye.git"

set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
set :deploy_to, "/home/tylersam/webapps/hawkeye"
set :shared_path, "/home/tylersam/webapps/hawkeye/shared"

role :web, "hawkeye.pitza42.com"                          # Your HTTP server, Apache/etc
role :app, "hawkeye.pitza42.com"                          # This may be the same as your `Web` server
role :db,  "hawkeye.pitza42.com", :primary => true # This is where Rails migrations will run

set :user, "tylersam"
set :scm_username, "tylersam"
set :use_sudo, false
default_run_options[:pty] = true

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end

require "rvm/capistrano"
require "bundler/capistrano"

set :rvm_ruby_string, :local              # use the same ruby as used locally for deployment
set :rvm_autolibs_flag, "read-only"       # more info: rvm help autolibs

before 'deploy:setup', 'rvm:install_rvm'  # install/update RVM
before 'deploy:setup', 'rvm:install_ruby' # install Ruby and create gemset, OR:
# before 'deploy:setup', 'rvm:create_gemset' # only create gemset

before "deploy:assets:precompile" do
  run ["ln -nfs #{shared_path}/config/settings.yml #{release_path}/config/settings.yml",
       "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml",
       "ln -nfs #{shared_path}/config/local_env.yml #{release_path}/config/local_env.yml",
       "ln -fs #{shared_path}/uploads #{release_path}/uploads"
  ].join(" && ")
end

namespace :deploy do
	desc "Restart nginx"
	task :restart do
		run "#{deploy_to}/bin/restart"
	end
end

namespace :delayed_job do
  desc "Start delayed_job process"
  task :start, :roles => :app do
    run "cd #{current_path}; bin/delayed_job start #{rails_env}"
  end
  
  desc "Stop delayed_job process"
  task :stop, :roles => :app do
    run "cd #{current_path}; bin/delayed_job stop #{rails_env}"
  end

  desc "Restart delayed_job process"
  task :restart, :roles => :app do
    run "cd #{current_path}; bin/delayed_job restart #{rails_env}"
  end
end

after "deploy:start", "delayed_job:start"
after "deploy:stop", "delayed_job:stop"
after "deploy:restart", "delayed_job:restart"