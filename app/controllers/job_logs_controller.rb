class JobLogsController < ApplicationController

	def index
		@job_logs = JobLog.all
	end

	def destroy 
		@job_log = JobLog.find(params[:id])
		@job_log.destroy
		respond_to do |format|
			format.html { redirect_to job_logs_url }
			format.json { head :no_content }
		end
	end
end