class MenuItemMailer < ActionMailer::Base
  default :from => "no-reply@pitza42.com",
  			:return_path => 'tyler@pitza42.com'

  	def menu_item_added(menu_item)
  		@menu_item = menu_item
  		#to_array = ["tyler@pitza42.com", "austin@pitza42.com"]
  		to_array = ["tyler@pitza42.com"]
  		mail to: to_array, :subject => "[Menu Item Added] #{menu_item.updated_at.strftime("%a - %m/%d/%Y %I:%M%p")}"
  	end	
end
