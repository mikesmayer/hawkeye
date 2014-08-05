class Tacos::MealCountRulesController < ApplicationController
  authorize_resource
  
  before_action :set_tacos_meal_count_rule, only: [:show, :edit, :update, :destroy]

  # GET /tacos/meal_count_rules
  # GET /tacos/meal_count_rules.json
  def index
    @tacos_meal_count_rules = Tacos::MealCountRule.all
  end

  # GET /tacos/meal_count_rules/1
  # GET /tacos/meal_count_rules/1.json
  def show
  end

  # GET /tacos/meal_count_rules/new
  def new
    @tacos_meal_count_rule = Tacos::MealCountRule.new
    @tacos_menu_item = Tacos::MenuItem.find(params[:menu_item])
  end

  # GET /tacos/meal_count_rules/1/edit
  def edit
    @tacos_menu_item = Tacos::MenuItem.find(params[:menu_item])
  end

  # POST /tacos/meal_count_rules
  # POST /tacos/meal_count_rules.json
  def create
    @tacos_meal_count_rule = Tacos::MealCountRule.new(tacos_meal_count_rule_params)

    respond_to do |format|
      if @tacos_meal_count_rule.save
        format.html { redirect_to @tacos_meal_count_rule, notice: 'Meal count rule was successfully created.' }
        format.json { render action: 'show', status: :created, location: @tacos_meal_count_rule }
        format.js   { render action: 'show', status: :created, location: @tacos_meal_count_rule }
      else
        format.html { render action: 'new' }
        format.json { render json: @tacos_meal_count_rule.errors, status: :unprocessable_entity }
        format.js   { render json: @tacos_meal_count_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tacos/meal_count_rules/1
  # PATCH/PUT /tacos/meal_count_rules/1.json
  def update
    respond_to do |format|
      if @tacos_meal_count_rule.update(tacos_meal_count_rule_params)
        format.html { redirect_to @tacos_meal_count_rule, notice: 'Meal count rule was successfully updated.' }
        format.json { head :no_content }
        format.js   { render action: 'show', status: :created, location: @tacos_meal_count_rule }
      else
        format.html { render action: 'edit' }
        format.json { render json: @tacos_meal_count_rule.errors, status: :unprocessable_entity }
        format.js   { render json: @tacos_meal_count_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tacos/meal_count_rules/1
  # DELETE /tacos/meal_count_rules/1.json
  def destroy
    @rule_id = @tacos_meal_count_rule.id
    @tacos_meal_count_rule.destroy

    respond_to do |format|
      format.html { redirect_to tacos_meal_count_rules_url }
      format.json { head :no_content }
      format.js   { render action: 'delete' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tacos_meal_count_rule
      @tacos_meal_count_rule = Tacos::MealCountRule.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tacos_meal_count_rule_params
      params.require(:tacos_meal_count_rule).permit(:menu_item_id, :meal_modifier, :start_date, :end_date)
    end
end
