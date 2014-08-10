# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

job_type :rake,  "cd :path && :environment_variable=:environment bundle exec rake :task -s :output"


set :output, '$HOME/logs/user/cron.log'

#10:30 am server time is 4:30 am central time, I think
every 1.day, :at => '10:30 am' do
	rake "hawkeye:sync_tacos_day"
end

every 1.day, :at => '10:45 am' do
	rake "hawkeye:sync_p42_item_sales"
end

every 1.day, :at => '9:00 am' do
	rake "hawkeye:sync_p42_revenue_groups"
end

every 1.day, :at => '9:05 am' do
	rake "hawkeye:sync_p42_menu_item_groups"
end

every 1.day, :at => '9:10 am' do
	rake "hawkeye:sync_p42_menu_items"
end
=begin
every 15.minutes do 
	rake "hawkeye:sync_tacos_day"
end
=end