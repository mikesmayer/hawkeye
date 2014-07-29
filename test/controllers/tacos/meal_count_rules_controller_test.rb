require 'test_helper'

class Tacos::MealCountRulesControllerTest < ActionController::TestCase
  setup do
    @tacos_meal_count_rule = tacos_meal_count_rules(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tacos_meal_count_rules)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tacos_meal_count_rule" do
    assert_difference('Tacos::MealCountRule.count') do
      post :create, tacos_meal_count_rule: { end_date: @tacos_meal_count_rule.end_date, meal_modifier: @tacos_meal_count_rule.meal_modifier, menu_item_id: @tacos_meal_count_rule.menu_item_id, start_date: @tacos_meal_count_rule.start_date }
    end

    assert_redirected_to tacos_meal_count_rule_path(assigns(:tacos_meal_count_rule))
  end

  test "should show tacos_meal_count_rule" do
    get :show, id: @tacos_meal_count_rule
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tacos_meal_count_rule
    assert_response :success
  end

  test "should update tacos_meal_count_rule" do
    patch :update, id: @tacos_meal_count_rule, tacos_meal_count_rule: { end_date: @tacos_meal_count_rule.end_date, meal_modifier: @tacos_meal_count_rule.meal_modifier, menu_item_id: @tacos_meal_count_rule.menu_item_id, start_date: @tacos_meal_count_rule.start_date }
    assert_redirected_to tacos_meal_count_rule_path(assigns(:tacos_meal_count_rule))
  end

  test "should destroy tacos_meal_count_rule" do
    assert_difference('Tacos::MealCountRule.count', -1) do
      delete :destroy, id: @tacos_meal_count_rule
    end

    assert_redirected_to tacos_meal_count_rules_path
  end
end
