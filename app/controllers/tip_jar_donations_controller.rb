class TipJarDonationsController < ApplicationController
  authorize_resource
  
  before_action :set_tip_jar_donation, only: [:show, :edit, :update, :destroy]

  # GET /tip_jar_donations
  # GET /tip_jar_donations.json
  def index
    @tip_jar_donations = TipJarDonation.all
  end

  # GET /tip_jar_donations/1
  # GET /tip_jar_donations/1.json
  def show
  end

  # GET /tip_jar_donations/new
  def new
    @tip_jar_donation = TipJarDonation.new
  end

  # GET /tip_jar_donations/1/edit
  def edit
  end

  # POST /tip_jar_donations
  # POST /tip_jar_donations.json
  def create
    @tip_jar_donation = TipJarDonation.new(tip_jar_donation_params)

    respond_to do |format|
      if @tip_jar_donation.save
        format.html { redirect_to @tip_jar_donation, notice: 'Tip jar donation was successfully created.' }
        format.json { render action: 'show', status: :created, location: @tip_jar_donation }
      else
        format.html { render action: 'new' }
        format.json { render json: @tip_jar_donation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tip_jar_donations/1
  # PATCH/PUT /tip_jar_donations/1.json
  def update
    respond_to do |format|
      if @tip_jar_donation.update(tip_jar_donation_params)
        format.html { redirect_to @tip_jar_donation, notice: 'Tip jar donation was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @tip_jar_donation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tip_jar_donations/1
  # DELETE /tip_jar_donations/1.json
  def destroy
    @tip_jar_donation.destroy
    respond_to do |format|
      format.html { redirect_to tip_jar_donations_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tip_jar_donation
      @tip_jar_donation = TipJarDonation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tip_jar_donation_params
      params.require(:tip_jar_donation).permit(:amount, :meals, :deposit_date, :restaurant_id)
    end
end
