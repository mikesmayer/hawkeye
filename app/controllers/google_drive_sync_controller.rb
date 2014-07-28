class GoogleDriveSyncController < ApplicationController

	def index
	end

	def file_list
		# The id is the id for P42 Reports folder in Drive
	    @file_list = GoogleDriveSync.get_file_list(params[:folder_id])
	    render :layout => false
	end

	def folder
		@folder_name = params[:folder_name]
		@file_list = GoogleDriveSync.get_file_list(params[:folder_id])
		render :layout => false
	end

	def get_file
		@file_contents = GoogleDriveSync.get_file(params[:file_id])
		
	end
end