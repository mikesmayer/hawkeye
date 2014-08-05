class FtpConnectsController < ApplicationController
  authorize_resource
  before_action :set_ftp_connect, only: [:show, :edit, :update, :destroy]

  # GET /ftp_connects
  # GET /ftp_connects.json
  def index
    @ftp_connects = FtpConnect.all
  end

  # GET /ftp_connects/1
  # GET /ftp_connects/1.json
  def show
  end

  # GET /ftp_connects/new
  def new
    @ftp_connect = FtpConnect.new
  end

  # GET /ftp_connects/1/edit
  def edit
  end

  # POST /ftp_connects
  # POST /ftp_connects.json
  def create
    @ftp_connect = FtpConnect.new(ftp_connect_params)

    respond_to do |format|
      if @ftp_connect.save
        format.html { redirect_to @ftp_connect, notice: 'Ftp connect was successfully created.' }
        format.json { render action: 'show', status: :created, location: @ftp_connect }
      else
        format.html { render action: 'new' }
        format.json { render json: @ftp_connect.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ftp_connects/1
  # PATCH/PUT /ftp_connects/1.json
  def update
    respond_to do |format|
      if @ftp_connect.update(ftp_connect_params)
        format.html { redirect_to @ftp_connect, notice: 'Ftp connect was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @ftp_connect.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ftp_connects/1
  # DELETE /ftp_connects/1.json
  def destroy
    @ftp_connect.destroy
    respond_to do |format|
      format.html { redirect_to ftp_connects_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ftp_connect
      @ftp_connect = FtpConnect.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ftp_connect_params
      params.require(:ftp_connect).permit(:server, :username, :password)
    end
end
