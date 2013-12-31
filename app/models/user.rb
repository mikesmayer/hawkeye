class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:google_oauth2]



  	# method called in the users\omniauth_callback_controller.rb file
  	# in that controller, the user's eamil is checked against the list of 
  	# approved_users. An error message saying  Not on the authorized list
  	# is displayed if they are approved.
  	def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
	    data = access_token.info
	    user = User.where(:email => data["email"]).first

	    unless user
	        user = User.create(name: data["name"],
	        			fname: data["first_name"],
	        			lname: data["last_name"],
		    		   email: data["email"],
		    		   password: Devise.friendly_token[0,20],
               role: 'admin'
		    		  )
	    end
	    user
	   end
end
