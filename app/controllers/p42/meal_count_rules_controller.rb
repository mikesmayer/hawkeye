class P42::MealCountRulesController < ApplicationController
  authorize_resource
  
  before_action :set_p42_meal_count_rule, only: [:show, :edit, :update, :destroy]

  # GET /p42/meal_count_rules
  # GET /p42/meal_count_rules.json
  def index
    @p42_meal_count_rules = P42::MealCountRule.all
  end

  # GET /p42/meal_count_rules/1
  # GET /p42/meal_count_rules/1.json
  def show
  end

  # GET /p42/meal_count_rules/new
  def new
    @p42_meal_count_rule = P42::MealCountRule.new
    @p42_menu_item = P42::MenuItem.find(params[:menu_item])
  end

  # GET /p42/meal_count_rules/1/edit
  def edit
    @p42_menu_item = P42::MenuItem.find(params[:menu_item])
  end

  # POST /p42/meal_count_rules
  # POST /p42/meal_count_rules.json
  def create
    @p42_meal_count_rule = P42::MealCountRule.new(p42_meal_count_rule_params)

    respond_to do |format|
      if @p42_meal_count_rule.save
        format.html { redirect_to @p42_meal_count_rule, notice: 'Meal count rule was successfully created.' }
        format.json { render action: 'show', status: :created, location: @p42_meal_count_rule }
        format.js   { render action: 'show', status: :created, location: @p42_meal_count_rule }
      else
        format.html { render action: 'new' }
        format.json { render json: @p42_meal_count_rule.errors, status: :unprocessable_entity }
        format.js   { render json: @p42_meal_count_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /p42/meal_count_rules/1
  # PATCH/PUT /p42/meal_count_rules/1.json
  def update
    respond_to do |format|
      if @p42_meal_count_rule.update(p42_meal_count_rule_params)
        format.html { redirect_to @p42_meal_count_rule, notice: 'Meal count rule was successfully updated.' }
        format.json { head :no_content }
        format.js { render action: 'show', status: :created, location: @p42_meal_count_rule }
      else
        format.html { render action: 'edit' }
        format.json { render json: @p42_meal_count_rule.errors, status: :unprocessable_entity }
        format.js { render json: @p42_meal_count_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /p42/meal_count_rules/1
  # DELETE /p42/meal_count_rules/1.json
  def destroy
    @rule_id = @p42_meal_count_rule.id
    @p42_meal_count_rule.destroy

    respond_to do |format|
      format.html { redirect_to p42_meal_count_rules_url }
      format.json { head :no_content }
      format.js    { render action: 'delete' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_p42_meal_count_rule
      @p42_meal_count_rule = P42::MealCountRule.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def p42_meal_count_rule_params
      params.require(:p42_meal_count_rule).permit(:menu_item_id, :start_date, :end_date, :meal_modifier)
    end
end
