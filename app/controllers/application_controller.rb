class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  check_authorization :unless => :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
  	  exception.default_message = "You are not authorized to view this page. You must either sign in or ask that your access level be changed."
	  flash[:error] = exception.message
	  redirect_to root_path
	end
end
