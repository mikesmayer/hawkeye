require 'test_helper'

class P42::MealCountRulesControllerTest < ActionController::TestCase
  setup do
    @p42_meal_count_rule = p42_meal_count_rules(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:p42_meal_count_rules)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create p42_meal_count_rule" do
    assert_difference('P42::MealCountRule.count') do
      post :create, p42_meal_count_rule: { end_date: @p42_meal_count_rule.end_date, meal_modifier: @p42_meal_count_rule.meal_modifier, p42_menu_item_id: @p42_meal_count_rule.p42_menu_item_id, start_date: @p42_meal_count_rule.start_date }
    end

    assert_redirected_to p42_meal_count_rule_path(assigns(:p42_meal_count_rule))
  end

  test "should show p42_meal_count_rule" do
    get :show, id: @p42_meal_count_rule
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @p42_meal_count_rule
    assert_response :success
  end

  test "should update p42_meal_count_rule" do
    patch :update, id: @p42_meal_count_rule, p42_meal_count_rule: { end_date: @p42_meal_count_rule.end_date, meal_modifier: @p42_meal_count_rule.meal_modifier, p42_menu_item_id: @p42_meal_count_rule.p42_menu_item_id, start_date: @p42_meal_count_rule.start_date }
    assert_redirected_to p42_meal_count_rule_path(assigns(:p42_meal_count_rule))
  end

  test "should destroy p42_meal_count_rule" do
    assert_difference('P42::MealCountRule.count', -1) do
      delete :destroy, id: @p42_meal_count_rule
    end

    assert_redirected_to p42_meal_count_rules_path
  end
end
