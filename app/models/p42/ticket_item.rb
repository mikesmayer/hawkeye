class P42::TicketItem < ActiveRecord::Base


	def get_p42_report_file_list


	end


	##
	#  Only using my @pitza42 account. It's the owner of the P42 Reports Folder and
	#  the Tacos Reports folder. This method looks up the refresh token for that account and
	#  creates a new client and drive
	#
	def self.setup_client
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

	def self.get_file_list
		setup_client
		result = Array.new
		
		# This folder id is for P42 Reports folder in Drive
		id_list = get_file_id_list('0B3s566IfxmitNVcwTE9rY0JkYmM')

		id_list.each do |id|
			api_result = @client.execute(
			  :api_method => @drive.files.get,
			  :parameters => { 'fileId' => id})
			if api_result.status == 200
			  file = api_result.data
			  puts file.title
			  puts YAML::dump(file)
			  


			  


		  	result << { "id" => file.id, 
		  				"title" => file.title }
			  

			  
			else
			  puts "An error occurred: #{result.data['error']['message']}"
			end
		end
		result
	end

	def self.save_file_to_local(file_id)
		ret_val = Hash.new

		api_result = @client.execute(
			  :api_method => @drive.files.get,
			  :parameters => { 'fileId' => file_id})
		if api_result.status == 200
		  file = api_result.data
		  if file.download_url
		    file_contents = @client.execute(:uri => file.download_url)
		    if file_contents.status == 200
		       
		       body = file_contents.body
		       title = file.title
		       
		       #name = "item_sales.csv"
		       #directory = "public/images/upload"

		    else
		      puts "An error occurred: #{result.data['error']['message']}"
		    end  
		  else
		    # The file doesn't have any content stored on Drive.
		  end
		  
		else
		  puts "An error occurred: #{result.data['error']['message']}"
		end



		ret_val = {"body" => body, "title" => title}	    
	end



end
