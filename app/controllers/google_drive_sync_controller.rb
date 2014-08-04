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
		@file_list = GoogleDriveSync.get_file_list(params[:folder_id], params[:scope])
		render :layout => false
	end

	def get_file
		@file_results = GoogleDriveSync.get_file(params[:file_id])
		
		response.header['Content-Type'] = 'application/json'
		respond_to do |format|
			format.html { render json: @file_results }
			format.js 	{ render json: @file_results }
			format.json { render json: @file_results }
		end
	end

	def search
		@gnditem_results = GoogleDriveSync.search_files(params[:search_term])
		render :layout => false
	end
end