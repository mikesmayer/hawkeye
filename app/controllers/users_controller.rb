class UsersController < ApplicationController
	authorize_resource

	def index
		@users = User.all

		respond_to do |format|
			format.html
		end
	end
	
	def show
	    @user = User.find(params[:id])
	  end
	  
	  def update
	    @user = User.find(params[:id])
	    respond_to do |format|
	      if @user.update_attributes(params[:user], :as => :admin)
	        format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
	        format.json { respond_with_bip(@user) }
	      else
	        format.html { render :action => "edit" }
	        format.json { respond_with_bip(@user) }
	      end
	    end
	  end
	    
	  def destroy
	    user = User.find(params[:id])
	    unless user == current_user
	      user.destroy
	      redirect_to users_path, :notice => "User deleted."
	    else
	      redirect_to users_path, :notice => "Can't delete yourself."
	    end
	  end

	private
    # Use callbacks to share common setup or constraints between actions.
    def set_approved_user
      @approved_user = ApprovedUser.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def approved_user_params
      params.require(:user).permit(:name, :fname, :lname, :email, :password, :password_confirmation, :remember_me, :role)
	end
end
