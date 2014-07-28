class GoogleDriveSync

	##
	#  Only using my @pitza42 account. It's the owner of the P42 Reports Folder and
	#  the Tacos Reports folder. This method looks up the refresh token for that account and
	#  creates a new client and drive
	#
	def self.setup_client
		
		if @drive.nil? || @client.nil?
			@tyler_p42 = User.find_by email: 'tyler@pitza42.com'

			puts @tyler_p42.inspect 

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
			
			puts YAML::dump(@client.authorization)

			@drive = @client.discovered_api('drive', 'v2')
		end

		{:drive => @drive, :client => @client }
	end


	def self.get_file_list(folder_id)
		GoogleDriveSync.setup_client
		result = Array.new
		
		# This folder id is for P42 Reports folder in Drive
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
			  

				if (file.mimeType == "application/vnd.google-apps.folder") || (["CAT.DBF", "CIT.DBF", "GNDITEM.DBF", "ITM.DBF"].include? file.title)
				  	result << { "id" => file.id, 
			  				"title" => file.title,
			  				"mimeType" => file.mimeType }

				end

			  
			else
			  puts "An error occurred: #{result.data['error']['message']}"
			end
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


	def self.parse_file(file_id)
		if @drive.nil?
			setup_client
		end



	end


	def self.get_file(file_id)
		if @drive.nil?
			setup_client
		end

		api_result = @client.execute(
			:api_method => @drive.files.get,
			:parameters => { 'fileId' => file_id})



		#Get file
		if api_result.status == 200
			file = api_result.data 

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

		if title == "CAT.DBF"
			file = File.binwrite("cat.dbf", body)
			cat_tbl = DBF::Table.new("cat.dbf")
			num_processed = GoogleDriveSync.process_tacos_category_dbf(cat_tbl)
		elsif title == "GNDITEM.DBF"
			file = File.binwrite("gnditem.dbf", body)
			item_tbl = DBF::Table.new("gnditem.dbf")
			num_processed = GoogleDriveSync.process_tacos_ticket_items_dbf(item_tbl)
		end
		
		
		#body is a string containing the contents of the downloaded file
		body
		num_processed
	end

	def self.search_files(search_term)
		if @drive.nil?
			setup_client
		end

		
	  result = Array.new
	  page_token = nil
	  begin
	    parameters = {'fields' => 'items(id,kind,mimeType,parents/id,title)',
	    				'q' => "title contains '#{search_term}'"}
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
	  	cleaned_array << {:id => file.id, :title => file.title, :parent_title => parent_title }
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


	def self.process_tacos_category_dbf(category_dbf)
		num_processed = 0
		category_dbf.each do |record|
			Tacos::MenuItemGroup.find_or_update_by_id(record.id, record.name)
			num_processed += 1
		end
		num_processed
	end


	def self.process_tacos_ticket_items_dbf(gnditem_dbf)
		num_processed = 0
		gnditem_dbf.each do |record|
			pos_ticket_item_id = record.entryid
			pos_ticket_id = record.check
			menu_item_id = record.item
			pos_category_id = record.category
			pos_revenue_class_id = record.revid
			quantity = record.quantity
			net_price = record.discpric
			discount_total = (record.price - record.discpric)
			item_menu_price = record.price
			ticket_close_time = DateTime.parse("#{record.dob}T#{record.hour}:#{record.minute}")


			Tacos::TicketItem.find_or_update_by_ticket_item_id(pos_ticket_item_id, pos_ticket_id, menu_item_id, pos_category_id, 
				pos_revenue_class_id, quantity, net_price, discount_total, item_menu_price, ticket_close_time)
			num_processed += 1
		end
		num_processed
	end


end