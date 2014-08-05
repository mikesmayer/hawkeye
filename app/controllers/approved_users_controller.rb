class ApprovedUsersController < ApplicationController
  authorize_resource
  
  before_action :set_approved_user, only: [:show, :edit, :update, :destroy]

  # GET /approved_users
  # GET /approved_users.json
  def index
    @approved_users = ApprovedUser.all
  end

  # GET /approved_users/1
  # GET /approved_users/1.json
  def show
  end

  # GET /approved_users/new
  def new
    @approved_user = ApprovedUser.new
  end

  # GET /approved_users/1/edit
  def edit
  end

  # POST /approved_users
  # POST /approved_users.json
  def create
    @approved_user = ApprovedUser.new(approved_user_params)

    respond_to do |format|
      if @approved_user.save
        format.html { redirect_to @approved_user, notice: 'Approved user was successfully created.' }
        format.json { render action: 'show', status: :created, location: @approved_user }
      else
        format.html { render action: 'new' }
        format.json { render json: @approved_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /approved_users/1
  # PATCH/PUT /approved_users/1.json
  def update
    respond_to do |format|
      if @approved_user.update(approved_user_params)
        format.html { redirect_to @approved_user, notice: 'Approved user was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @approved_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /approved_users/1
  # DELETE /approved_users/1.json
  def destroy
    @approved_user.destroy
    respond_to do |format|
      format.html { redirect_to approved_users_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_approved_user
      @approved_user = ApprovedUser.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def approved_user_params
      params.require(:approved_user).permit(:name, :email)
    end
end
