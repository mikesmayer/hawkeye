class GoogleDriveSync

	@@tacos_file_list = ["CAT.DBF", "CIT.DBF", "GNDITEM.DBF", "ITM.DBF", "GNDVOID.DBF"]
	@@client = nil
	##
	#  Only using my @pitza42 account. It's the owner of the P42 Reports Folder and
	#  the Tacos Reports folder. This method looks up the refresh token for that account and
	#  creates a new client and drive
	#
	def self.setup_client
		
		if @drive.nil? || @client.nil?
			@tyler_p42 = User.find_by email: 'tyler@pitza42.com'

			#puts @tyler_p42.inspect 

			@client = Google::APIClient.new(
				application_name: "TestApp",
				application_version: "1.0.0"
			)
			@client.authorization.client_id = ENV['GOOGLE_AUTH_CLIENT_ID']
			@client.authorization.client_secret = ENV['GOOGLE_AUTH_CLIENT_SECRET']
			@client.authorization.grant_type = 'refresh_token'
			@client.authorization.refresh_token = @tyler_p42.refresh_token

			#puts YAML::dump(@client.authorization)

			@client.authorization.fetch_access_token!
			@client.authorization
			
			#puts YAML::dump(@client.authorization)

			@drive = @client.discovered_api('drive', 'v2')
			@@client = @client
		end

		{ :drive => @drive, :client => @client }
	end


	def self.get_file_list(folder_id, scope)
		GoogleDriveSync.setup_client
		result = Array.new
		
		if scope == "all"
			# This flow will return a list of all the files in the given folder
			id_list = get_file_id_list(folder_id)

			id_list.each do |id|
				api_result = @client.execute(
				  :api_method => @drive.files.get,
				  :parameters => { 'fileId' => id,
				  					'fields' => 'id,mimeType,title' })
				if api_result.status == 200
				  file = api_result.data
				  puts file.title
				  puts YAML::dump(file)
				  

					result << { :id => file.id, 
				  				:title => file.title,
				  				:mime_type => file.mimeType }

					

				  
				else
				  puts "An error occurred: #{result.data['error']['message']}"
				end
			end
		elsif scope == "filtered"
			#this "filtered" flow will search for each of the files in the @@tacos_file_list array
			result = get_dbf_files_for_day(folder_id)

		end

		result
	end




	def self.get_file_id_list(folderId)
		result = Array.new
		page_token = nil

		begin
			parameters = {'folderId' => folderId}
			if page_token.to_s != ''
			  parameters['pageToken'] = page_token
			end
			api_result = @client.execute(
			  :api_method => @drive.children.list,
			  :parameters => parameters)
			if api_result.status == 200
			  children = api_result.data

			  file_details = Hash.new
			  children.items.each do |item|
			  	#puts item.id
			  	#puts item['title']
			  	#file_details = { "id" => item['id'], "title" => "empty"}
			  	#result << file_details
			  	result << item['id']
			  end
			  


			  page_token = children.next_page_token
			else
			  puts "An error occurred: #{result.data['error']['message']}"
			  page_token = nil
			end
		end while page_token.to_s != ''
		result
	end


	##
	# Move a file to the trash
	#
	# @param [Google::APIClient] client
	#   Authorized client instance
	# @param [String] file_id
	#   ID of the file to trash
	# @return [Google::APIClient::Schema::Drive::V2::File]
	#   The updated file if successful, nil otherwise
	def self.trash_file(file_id)
	  drive = @@client.discovered_api('drive', 'v2')
	  result = @@client.execute(
	    :api_method => drive.files.trash,
	    :parameters => { 'fileId' => file_id })
	  if result.status == 200
	    return result.data
	  else
	    puts "An error occurred: #{result.data['error']['message']}"
	  end
	end

	def self.get_file(file_id)
		if @drive.nil?
			setup_client
		end

		api_result = @client.execute(
			:api_method => @drive.files.get,
			:parameters => { 'fileId' => file_id,
							'fields' => 'downloadUrl,id,mimeType,title' })



		#Get file
		if api_result.status == 200
			file = api_result.data 
			mime_type = file.mimeType

			#Download file
			if file.download_url

				puts YAML::dump(file)
				file_contents = @client.execute(:uri => file.download_url)

				#puts YAML::dump(file_contents)

				if file_contents.status == 200
					body = file_contents.body
					title = file.title
				end

			else
				#File has no contents on drive therefore not download_url
			end

		else
			#status was not 200
		end

		puts "title"
		puts title

		if title == "CAT.DBF"
			file = File.binwrite("cat.dbf", body)
			cat_tbl = DBF::Table.new("cat.dbf")
			results = GoogleDriveSync.process_tacos_category_dbf(cat_tbl)

			
			## log entry
=begin
			JobLog.create(:job_type => "manual", :date_run => DateTime.now, :folder_name => "",
				:file_name => "CAT.DBF", :method_name => results[:method], 
				:model_name => results[:model], :error_ids => results[:error_ids],
				:num_processed => results[:num_processed], :num_errors => results[:errors],
				:num_updated => results[:updates], :num_created => results[:creates])
=end
		elsif title == "GNDITEM.DBF"
			file = File.binwrite("gnditem.dbf", body)
			item_tbl = DBF::Table.new("gnditem.dbf")
			results = GoogleDriveSync.process_tacos_ticket_items_dbf(item_tbl)

			## log entry
=begin
			JobLog.create(:job_type => "manual", :date_run => DateTime.now, :folder_name => "",
				:file_name => "GNDITEM.DBF", :method_name => results[:method], 
				:model_name => results[:model], :error_ids => results[:error_ids],
				:num_processed => results[:num_processed], :num_errors => results[:errors],
				:num_updated => results[:updates], :num_created => results[:creates])
=end
		elsif title == "ITM.DBF"
			file = File.binwrite("itm.dbf", body)
			menu_time_tbl = DBF::Table.new("itm.dbf")
			results = GoogleDriveSync.process_tacos_menu_item_dbf(menu_time_tbl)

			## log entry
=begin
			JobLog.create(:job_type => "manual", :date_run => DateTime.now, :folder_name => "",
				:file_name => "ITM.DBF", :method_name => results[:method], 
				:model_name => results[:model], :error_ids => results[:error_ids],
				:num_processed => results[:num_processed], :num_errors => results[:errors],
				:num_updated => results[:updates], :num_created => results[:creates])
=end
		elsif title == "CIT.DBF"
			file = File.binwrite("cit.dbf", body)
			item_cat_join_tbl = DBF::Table.new("cit.dbf")
			results = GoogleDriveSync.process_tacos_menu_item_categories(item_cat_join_tbl)
		
			## log entry
=begin
			JobLog.create(:job_type => "manual", :date_run => DateTime.now, :folder_name => "",
				:file_name => "CIT.DBF", :method_name => results[:method], 
				:model_name => results[:model], :error_ids => results[:error_ids],
				:num_processed => results[:num_processed], :num_errors => results[:errors],
				:num_updated => results[:updates], :num_created => 0)
=end

		elsif title == "GNDVOID.DBF"
			file = File.binwrite("gndvoid.dbf", body)
			void_tbl = DBF::Table.new("gndvoid.dbf")
			results = GoogleDriveSync.process_voids_dbf(void_tbl)

			## log entry
=begin
			JobLog.create(:job_type => "manual", :date_run => DateTime.now, :folder_name => "",
				:file_name => "GNDVOID.DBF", :method_name => results[:method], 
				:model_name => results[:model], :error_ids => results[:error_ids],
				:num_processed => results[:num_processed], :num_errors => results[:errors],
				:num_updated => results[:updates], :num_created => 0)
=end
			

		elsif mime_type == "application/vnd.google-apps.folder"

	
		elsif title.include? "item_sales"
			csv_rows = Array.new
			body = body.strip

			csv = CSV.new(body, :headers => true, :header_converters => :symbol, :converters => :all, :col_sep => ";", :quote_char => "|")
			csv = csv.to_a.map {|row| row.to_hash }

			results = GoogleDriveSync.process_p42_item_sales_csv(csv)
			
			## log entry
=begin
			JobLog.create(:job_type => "manual", :date_run => DateTime.now, :folder_name => "P42 Reports",
				:file_name => title, :method_name => results[:method], 
				:model_name => results[:model], :error_ids => results[:error_ids],
				:num_processed => results[:num_processed], :num_errors => results[:errors],
				:num_updated => results[:updates], :num_created => results[:creates])
=end	


		end

		results
	end

	def self.search_files(search_term)
		if @drive.nil?
			setup_client
		end

		
	  result = Array.new
	  page_token = nil
	  begin
	    parameters = {'fields' => 'items(id,kind,mimeType,parents/id,title)',
	    				'q' => search_term}
	    if page_token.to_s != ''
	      parameters['pageToken'] = page_token
	    end
	    api_result = @client.execute(
	      :api_method => @drive.files.list,
	      :parameters => parameters)
	    if api_result.status == 200
	      files = api_result.data

	      result.concat(files.items)
	      page_token = files.next_page_token
	    else
	      puts "An error occurred: #{result.data['error']['message']}"
	      page_token = nil
	    end
	  end while page_token.to_s != ''
	  result

	  cleaned_array = Array.new
	  result.each do |file|

	  	parent_title = GoogleDriveSync.get_file_title(file.parents[0].id)
	  	cleaned_array << {:id => file.id, :title => file.title, :parent_title => parent_title, :mime_type => file.mimeType }
	  end
		YAML::dump(cleaned_array)

		cleaned_array

	end

	def self.get_file_title(file_id)
		if @drive.nil?
			setup_client
		end

		api_result = @client.execute(
			:api_method => @drive.files.get,
			:parameters => { 'fileId' => file_id, 
							'fields' => 'title'} )

		title = "File not found"


		#Get file
		if api_result.status == 200
			file = api_result.data 

			title = file.title
		else
			#status was not 200
		end
		title
	end

	def self.get_dbf_files_for_day(folder_id)

		title_list = ""
		@@tacos_file_list.each_with_index do |file_name, index|
			if index == 0
				title_list = "title = '#{file_name}'"			
			else
				title_list.concat(" or title = '#{file_name}'")
			end
		end
		q = "'#{folder_id}' in parents and (#{title_list})"
		
		search_files(q)
	end


	def self.process_tacos_category_dbf(category_dbf)
		results = { :num_processed => 0, :errors => 0, :creates => 0, :updates => 0, 
			:method => "process_tacos_category_dbf", :model => "Tacos::MenuItemGroup", :error_ids => nil }
		error_ids = Array.new

		category_dbf.each do |record|
			cat_results = Tacos::MenuItemGroup.find_or_update_by_id(record.id, record.name)
			if cat_results[:error].nil?
				#processed correctly 
				if cat_results[:action] == "create"
					results[:creates] += 1	
				elsif cat_results[:action] == "update"
					results[:updates] += 1
				end
			else
				#some error occured
				results[:errors] += 1
				error_ids << results[:obj].id
			end
			results[:num_processed] += 1
		end
		results[:error_ids] = error_ids.join(",")
		results
	end


	def self.process_tacos_ticket_items_dbf(gnditem_dbf)
		results = { :num_processed => 0, :errors => 0, :creates => 0, :updates => 0, 
			:method => "process_tacos_ticket_items", :model => "Tacos::TicketItem", :error_ids => nil }
		error_ids = Array.new
		
		gnditem_dbf.each do |record|
			pos_ticket_item_id = record.entryid
			date_of_business = record.dob
			pos_ticket_id = record.check
			menu_item_id = record.item
			pos_category_id = record.category
			pos_revenue_class_id = record.revid
			quantity = record.quantity
			net_price = record.discpric
			discount_total = (record.price - record.discpric)
			item_menu_price = record.price
			ticket_close_time = DateTime.parse("#{record.dob}T#{record.hour}:#{record.minute}")


			ticket_item_result = Tacos::TicketItem.find_or_update_by_ticket_item_id_and_date(pos_ticket_item_id, date_of_business, 
				pos_ticket_id, menu_item_id, pos_category_id, 
				pos_revenue_class_id, quantity, net_price, discount_total, item_menu_price, ticket_close_time)
			
			#record the results in the results hash
			if ticket_item_result[:error].nil?
				if ticket_item_result[:action] == "create"
					results[:creates] += 1	
				elsif ticket_item_result[:action] == "update"
					results[:updates] += 1
				end
			else
				results[:errors] += 1
				error_ids << ticket_item_result[:obj_id]
			end
			results[:num_processed] += 1
		end
		results[:error_ids] = error_ids.join(",")
		results
	end


	def self.process_tacos_menu_item_dbf(itm_dbf)
		results = { :num_processed => 0, :errors => 0, :creates => 0, :updates => 0, 
			:method => "process_tacos_menu_items_dbf", :model => "Tacos::MenuItem", :error_ids => nil }
		error_ids = Array.new


		itm_dbf.each do |menu_item|
			unless menu_item.longname.empty? || menu_item.longname.include?('***')
				menu_item_results = Tacos::MenuItem.find_or_update_by_id(menu_item.id, menu_item.longname)
				
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
					error_ids << menu_item_results[:obj].id
				end
				results[:num_processed] += 1
			end			
		end
		results[:error_ids] = error_ids.join(",")
		results
	end

	def self.process_tacos_menu_item_categories(item_cat_join_dbf)
		results = { :num_processed => 0, :errors => 0, :updates => 0, 
			:method => "process_tacos_menu_item_categories", :model => "Tacos::MenuItem", :error_ids => nil }
		error_ids = Array.new

		item_cat_join_dbf.each do |record|
			#category 12 is All but Mdse (not a real category)
			#category 13 is All tacos (not a real category)
			#category 20 is All items (not a real category)
			if record.category != 12 && record.category != 13 && record.category != 20

				menu_item = Tacos::MenuItem.find_by_id(record.itemid)
				unless menu_item.nil?
					if menu_item.update_attributes(:menu_item_group_id => record.category)
						results[:updates] += 1
					else
						results[:errors] += 1
						error_ids << menu_item.id
					end
					results[:num_processed] += 1	
				end		

			end	
		end
		results[:error_ids] = error_ids.join(",")
		results
	end

	def self.process_voids_dbf(voids_dbf)
		results = { :num_processed => 0, :errors => 0, :updates => 0, 
			:method => "process_voids_dbf", :model => "Tacos::TicketItem", :error_ids => nil }
		error_ids = Array.new

		voids_dbf.each do |record|
			pos_ticket_item_id = record.entryid
			date_of_business = record.date

			#puts pos_ticket_item_id
			#puts date_of_business
			
			ticket_item = Tacos::TicketItem.find_by_pos_ticket_item_id_and_dob(pos_ticket_item_id, date_of_business)
			unless ticket_item.nil?
				if ticket_item.update_attributes(:void => true, :meal_for_meal => 0)
					results[:updates] += 1
				else
					results[:errors] += 1
					error_ids << ticket_item.id
				end
				results[:num_processed] += 1
			end
			
		end
		results[:error_ids] = error_ids.join(",")
		results
	end

	def self.process_p42_item_sales_csv(item_sales_csv)
		results = { :num_processed => 0, :errors => 0, :updates => 0, :creates => 0,
			:method => "process_p42_item_sales_csv", :model => "P42::TicketItem", :error_ids => nil }
		error_ids = Array.new

		item_sales_csv.each do |row|
			if (row[:ticket_item_id].is_a? Numeric)
				
				#Discount total null check
				if row[:discount_total] == "NULL"
					row[:discount_total] = 0
				end

				#customer id check
				if row[:customer_original_id] == "NULL"
					row[:customer_original_id] = 0
				end

				ticket_item_results = P42::TicketItem.find_or_update_by_ticket_item_id(
					row[:ticket_item_id],
					row[:ticket_id],
					row[:menu_item_id],
					row[:i_price_category_id],
					row[:i_revenue_class],
					row[:customer_original_id],
					row[:quantity],
					row[:net_price],
					row[:discount_total],
					row[:item_menu_price],					
					row[:choice_additions_total],				
					row[:ticket_close_time],					
					-1)

				#record the results in the results hash
				if ticket_item_results[:error].nil?
					if ticket_item_results[:action] == "create"
						results[:creates] += 1	
					elsif ticket_item_results[:action] == "update"
						results[:updates] += 1
					end
				else
					results[:errors] += 1
					error_ids << ticket_item_results[:obj_id]
				end
				results[:num_processed] += 1
			end
			
		end
		results[:error_ids] = error_ids.join(",")
		results
		
	end

end