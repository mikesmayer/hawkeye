class OneTimeDonationsController < ApplicationController
  authorize_resource
  
  before_action :set_one_time_donation, only: [:show, :edit, :update, :destroy]

  # GET /one_time_donations
  # GET /one_time_donations.json
  def index
    @one_time_donations = OneTimeDonation.all
  end

  # GET /one_time_donations/1
  # GET /one_time_donations/1.json
  def show
  end

  # GET /one_time_donations/new
  def new
    @one_time_donation = OneTimeDonation.new
  end

  # GET /one_time_donations/1/edit
  def edit
  end

  # POST /one_time_donations
  # POST /one_time_donations.json
  def create
    @one_time_donation = OneTimeDonation.new(one_time_donation_params)

    respond_to do |format|
      if @one_time_donation.save
        format.html { redirect_to @one_time_donation, notice: 'One time donation was successfully created.' }
        format.json { render action: 'show', status: :created, location: @one_time_donation }
      else
        format.html { render action: 'new' }
        format.json { render json: @one_time_donation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /one_time_donations/1
  # PATCH/PUT /one_time_donations/1.json
  def update
    respond_to do |format|
      if @one_time_donation.update(one_time_donation_params)
        format.html { redirect_to @one_time_donation, notice: 'One time donation was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @one_time_donation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /one_time_donations/1
  # DELETE /one_time_donations/1.json
  def destroy
    @one_time_donation.destroy
    respond_to do |format|
      format.html { redirect_to one_time_donations_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_one_time_donation
      @one_time_donation = OneTimeDonation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def one_time_donation_params
      params.require(:one_time_donation).permit(:description, :amount, :meals, :deposit_date, :restaurant_id)
    end
end
