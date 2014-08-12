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

		today = (DateTime.now - 2.days).strftime("%Y%m%d")
		puts "Searching for:"
		#today = "20140820"
		puts today

		sync_date(today)
	end

	desc "Checks P42 Reports folder in Drive for new item sales files and processes the CSV"
	task :sync_p42_item_sales => :environment do 
		@job_type = "rake"

		#P42 Reports folder id is 0B3s566IfxmitNVcwTE9rY0JkYmM
		query = "'0B3s566IfxmitNVcwTE9rY0JkYmM' in parents and mimeType = 'text/csv' and trashed=false"

		# search for all csv's in the P42 Folder
		files_array = GoogleDriveSync.search_files(query)

		# process each CSV found
		files_array.each do |file|
			puts file.inspect
			process_p42_item_sales_csv(file[:id], file[:title])
			#move CSV to trash once processed
			GoogleDriveSync.trash_file(file[:id])
		end


	end

	desc "Synchronizes all menu items from P42's POS."
	task :sync_p42_menu_items => :environment do
		@job_type = "rake"

		initialize_soap    
	   	menu_item_response = get_menu_items
	   	
	   	results = process_p42_menu_items(menu_item_response)
		
		JobLog.create(:job_type => @job_type, :date_run => DateTime.now, :folder_name => "DW Soap",
				:file_name => "", :method_name => results[:method], 
				:model_name => results[:model], :error_ids => results[:error_ids],
				:num_processed => results[:num_processed], :num_errors => results[:errors],
				:num_updated => results[:updates], :num_created => results[:creates])
	end


	desc "Synchronizes all item groups from P42's POS."
	task :sync_p42_menu_item_groups => :environment do
		@job_type = "rake"

	    initialize_soap
	    
	   	groups_response = get_menu_item_groups
	   	
	   	results = process_p42_menu_item_groups(groups_response)

		JobLog.create(:job_type => @job_type, :date_run => DateTime.now, :folder_name => "DW Soap",
				:file_name => "", :method_name => results[:method], 
				:model_name => results[:model], :error_ids => results[:error_ids],
				:num_processed => results[:num_processed], :num_errors => results[:errors],
				:num_updated => results[:updates], :num_created => results[:creates])
	end


	desc "Synchronizes all revenue groups with P42's POS."
	task :sync_p42_revenue_groups => :environment do
		@job_type = "rake"

		initialize_soap

		rev_class_response = get_revenue_groups

		results = process_p42_revenue_classes(rev_class_response)

		JobLog.create(:job_type => @job_type, :date_run => DateTime.now, :folder_name => "DW Soap",
				:file_name => "", :method_name => results[:method], 
				:model_name => results[:model], :error_ids => results[:error_ids],
				:num_processed => results[:num_processed], :num_errors => results[:errors],
				:num_updated => results[:updates], :num_created => results[:creates])
	end


	def sync_date(date)
		# find the folder that is named with todays date in the format above
		daily_folder = GoogleDriveSync.search_files("title = '#{date}' and trashed=false").first
		puts "Search results:"
		puts daily_folder
		if daily_folder.nil?
			JobLog.create(:job_type => @job_type, :date_run => DateTime.now, :folder_name => @folder_title,
			:file_name => "", :method_name => "sync_date", 
			:model_name => "No results found for search: title = #{date}", :error_ids => "",
			:num_processed => 0, :num_errors => 1,
			:num_updated => 0, :num_created => 0)
		else 
			#found folder for the given date
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




	### P42 SECTION for soap calls - used for menu items, categories and revenue classes ### 
	def process_p42_item_sales_csv(file_id, file_title)
		results = GoogleDriveSync.get_file(file_id)
		puts "P42 CSV Results"
		puts results

		JobLog.create(:job_type => @job_type, :date_run => DateTime.now, :folder_name => "P42 Reports",
				:file_name => file_title, :method_name => results[:method], 
				:model_name => results[:model], :error_ids => results[:error_ids],
				:num_processed => results[:num_processed], :num_errors => results[:errors],
				:num_updated => results[:updates], :num_created => results[:creates])
	end


	def initialize_soap
		@client = Savon.client(wsdl: Restaurant.find(1).soap_url, endpoint: Restaurant.find(1).soap_endpoint)
	end

	def get_menu_items
		response = @client.call(:get_all_menu_items)
		response.body[:get_all_menu_items_response][:get_all_menu_items_result][:menu_item]
	end


	def get_menu_item_groups
		response = @client.call(:get_all_item_groups)
		response.body[:get_all_item_groups_response][:get_all_item_groups_result][:item_group]
	end


	def get_revenue_groups
		response = @client.call(:get_all_revenue_classes)
		response.body[:get_all_revenue_classes_response][:get_all_revenue_classes_result][:revenue_class]
	end

	def process_p42_menu_items(menu_items)
		results = { :num_processed => 0, :errors => 0, :creates => 0, :updates => 0, 
			:method => "process_p42_menu_items", :model => "P42::MenuItem", :error_ids => nil }
		error_ids = Array.new

		menu_items.each do |menu_item|
			id = menu_item[:id]
			name = menu_item[:item_name]
			item_group_id = menu_item[:price_cat_id]
			if item_group_id.nil?  || item_group_id.to_i < 0 
				item_group_id = 0
			end
			revenue_class_id = menu_item[:revenue_class_id]
			gross_price = menu_item[:price].to_f
			
			menu_item_results = P42::MenuItem.find_or_update_by_id(id, name, item_group_id, revenue_class_id, gross_price)
	   		
	   		if menu_item_results[:error].nil?
				#processed correctly 
				if menu_item_results[:action] == "create"
					results[:creates] += 1	
				elsif menu_item_results[:action] == "update"
					results[:updates] += 1
				end
			else
				#some error occured
				results[:errors] += 1
				error_ids << menu_item_results[:obj_id]
			end
			results[:num_processed] += 1

	   	end
	   	puts "Sync completed successfully"

		results[:error_ids] = error_ids.join(",")
		results
	end

	def process_p42_menu_item_groups(item_groups)
		results = { :num_processed => 0, :errors => 0, :creates => 0, :updates => 0, 
			:method => "process_p42_menu_item_groups", :model => "P42::MenuItemGroup", :error_ids => nil }
		error_ids = Array.new

		item_groups.each do |menu_item_group|
			id = menu_item_group[:id]
			name = menu_item_group[:description]		
			
			menu_item_group_results = P42::MenuItemGroup.find_or_update_by_id(id, name)


			if menu_item_group_results[:error].nil?
				#processed correctly 
				if menu_item_group_results[:action] == "create"
					results[:creates] += 1	
				elsif menu_item_group_results[:action] == "update"
					results[:updates] += 1
				end
			else
				#some error occured
				results[:errors] += 1
				error_ids << menu_item_group_results[:obj_id]
			end
			results[:num_processed] += 1

	   	end
	   	
	   	puts "Sync completed successfully"
	   	results[:error_ids] = error_ids.join(",")
		results
	end

	def process_p42_revenue_classes(revenue_classes)
		results = { :num_processed => 0, :errors => 0, :creates => 0, :updates => 0, 
			:method => "process_p42_revenue_classes", :model => "P42::RevenueGroup", :error_ids => nil }
		error_ids = Array.new

		revenue_classes.each do |revenue_class|
			id = revenue_class[:id]
			name = revenue_class[:description]		

			rev_classes_results = P42::RevenueGroup.find_or_update_by_id(id, name)

			if rev_classes_results[:error].nil?
				#processed correctly 
				if rev_classes_results[:action] == "create"
					results[:creates] += 1	
				elsif rev_classes_results[:action] == "update"
					results[:updates] += 1
				end
			else
				#some error occured
				results[:errors] += 1
				error_ids << rev_classes_results[:obj_id]
			end
			results[:num_processed] += 1

		end
		puts "Sync completed successfully"
		results[:error_ids] = error_ids.join(",")
		results
	end
end