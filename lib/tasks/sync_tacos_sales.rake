namespace :hawkeye do 
	desc "Test task"
	task :test_cron_jobs => :environment do 
		JobLog.create(:job_type => "Test", :date_run => DateTime.now, :folder_name => '',
			:file_name => "", :method_name => 'test_cron_jobs', 
			:model_name => 'Test', :error_ids => '',
			:num_processed => 0, :num_errors => 0,
			:num_updated => 0, :num_created => 0)

	end

	desc "Syncronizes Taco's menu and sales for the day"
	task :sync_tacos_day => :environment do
		GoogleDriveSync.setup_client

		@job_type = "rake"

		today = (DateTime.now - 1.days).strftime("%Y%m%d")
		puts "Searching for:"
		#today = "20140621"
		puts today

		sync_date(today)
	end


	def sync_date(date)
		# find the folder that is named with todays date in the format above
		daily_folder = GoogleDriveSync.search_files("title = '#{date}'").first
		puts "Search results:"
		puts daily_folder

		@folder_title = daily_folder[:title]

		#get folder contents the second param is the scope - filtered will only return the DBF files we want to parse
		file_list = GoogleDriveSync.get_file_list(daily_folder[:id], "filtered")
		puts file_list

		cat_file = file_list.detect { |f| f[:title] == "CAT.DBF" }
		puts "cat file:"
		puts cat_file

		menu_itm_file = file_list.detect { |f| f[:title] == "ITM.DBF" }
		puts "menu items file:"
		puts menu_itm_file

		cat_itm_join_file = file_list.detect { |f| f[:title] == "CIT.DBF" }
		puts "category item join file:"
		puts cat_itm_join_file

		ticket_item_file = file_list.detect { |f| f[:title] == "GNDITEM.DBF" }
		puts "daily sales ticket items file:"
		puts ticket_item_file

		void_file = file_list.detect { |f| f[:title] == "GNDVOID.DBF" }
		puts "void file:"
		puts void_file

		puts
		puts

		process_tacos_category(cat_file[:id])
		process_tacos_menu_items(menu_itm_file[:id])
		process_cat_menu_item_join(cat_itm_join_file[:id])
		process_daily_sales(ticket_item_file[:id])
		process_voids(void_file[:id])

	end


	def process_tacos_category(file_id)
		results = GoogleDriveSync.get_file(file_id)
		puts "Category results:"
		puts results

		JobLog.create(:job_type => @job_type, :date_run => DateTime.now, :folder_name => @folder_title,
			:file_name => "CAT.DBF", :method_name => results[:method], 
			:model_name => results[:model], :error_ids => results[:error_ids],
			:num_processed => results[:num_processed], :num_errors => results[:errors],
			:num_updated => results[:updates], :num_created => results[:creates])

	end

	def process_tacos_menu_items(file_id)
		results = GoogleDriveSync.get_file(file_id)
		puts "Menu items results:"
		puts results
		
		JobLog.create(:job_type => @job_type, :date_run => DateTime.now, :folder_name => @folder_title,
			:file_name => "ITM.DBF", :method_name => results[:method], 
			:model_name => results[:model], :error_ids => results[:error_ids],
			:num_processed => results[:num_processed], :num_errors => results[:errors],
			:num_updated => results[:updates], :num_created => results[:creates])
	end

	def process_cat_menu_item_join(file_id)
		results = GoogleDriveSync.get_file(file_id)
		puts "Menu Item Category join results:"
		puts results

		JobLog.create(:job_type => @job_type, :date_run => DateTime.now, :folder_name => @folder_title,
			:file_name => "CIT.DBF", :method_name => results[:method], 
			:model_name => results[:model], :error_ids => results[:error_ids],
			:num_processed => results[:num_processed], :num_errors => results[:errors],
			:num_updated => results[:updates], :num_created => 0)
	end


	def process_daily_sales(file_id)
		results = GoogleDriveSync.get_file(file_id)
		puts "Ticket items results:"
		puts results

		JobLog.create(:job_type => @job_type, :date_run => DateTime.now, :folder_name => @folder_title,
			:file_name => "GNDITEM.DBF", :method_name => results[:method], 
			:model_name => results[:model], :error_ids => results[:error_ids],
			:num_processed => results[:num_processed], :num_errors => results[:errors],
			:num_updated => results[:updates], :num_created => results[:creates])
	end


	def process_voids(file_id)
		results = GoogleDriveSync.get_file(file_id)
		puts "Voids results:"
		puts results

		JobLog.create(:job_type => @job_type, :date_run => DateTime.now, :folder_name => @folder_title,
			:file_name => "GNDVOID.DBF", :method_name => results[:method], 
			:model_name => results[:model], :error_ids => results[:error_ids],
			:num_processed => results[:num_processed], :num_errors => results[:errors],
			:num_updated => results[:updates], :num_created => 0)

	end



end


