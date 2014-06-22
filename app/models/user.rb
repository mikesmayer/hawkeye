require 'google/api_client'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:google_oauth2]
  serialize :credentials, Hash


  	# method called in the users\omniauth_callback_controller.rb file
  	# in that controller, the user's eamil is checked against the list of 
  	# approved_users. An error message saying  Not on the authorized list
  	# is displayed if they are approved.
  	def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
	    data = access_token.info
	    token = access_token.credentials["token"]
	    refresh_token = access_token.credentials["refresh_token"]
	    #credentials_serialized = access_token.credentials.serialize

	    user = User.where(:email => data["email"]).first

	    unless user
	        user = User.create(name: data["name"],
	        			fname: data["first_name"],
	        			lname: data["last_name"],
		    		    email: data["email"],
		    		    password: Devise.friendly_token[0,20],
               			role: 'admin',
               			token: token,
               			refresh_token: refresh_token
		    		  )
	    end
	    user
	end

	##
	#  Only using my @pitza42 account. It's the owner of the P42 Reports Folder and
	#  the Tacos Reports folder. This method looks up the refresh token for that account and
	#  creates a new client and drive
	#
	def setup_client
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

	def get_file_id_list(folderId)
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

	def get_file_list
		setup_client
		result = Array.new
		

		id_list = get_file_id_list('0B3s566IfxmitMGdEYjZsWEpJdjA')

		id_list.each do |id|
			api_result = @client.execute(
			  :api_method => @drive.files.get,
			  :parameters => { 'fileId' => id})
			if api_result.status == 200
			  file = api_result.data
			  result << { "id" => file.id, "title" => file.title }
			  
			else
			  puts "An error occurred: #{result.data['error']['message']}"
			end
		end
		result
	end



	##
	# Store OAuth 2.0 credentials in the application's database.
	#
	# @param [String] user_id
	#   User's ID.
	# @param [Signet::OAuth2::Client] credentials
	#   OAuth 2.0 credentials to store.
	def store_credentials(user_id, credentials)
	  
	end

end
