require 'test_helper'

class P42::MenuItemGroupsControllerTest < ActionController::TestCase
  setup do
    @p42_menu_item_group = p42_menu_item_groups(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:p42_menu_item_groups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create p42_menu_item_group" do
    assert_difference('P42::MenuItemGroup.count') do
      post :create, p42_menu_item_group: { default_meal_modifier: @p42_menu_item_group.default_meal_modifier, name: @p42_menu_item_group.name }
    end

    assert_redirected_to p42_menu_item_group_path(assigns(:p42_menu_item_group))
  end

  test "should show p42_menu_item_group" do
    get :show, id: @p42_menu_item_group
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @p42_menu_item_group
    assert_response :success
  end

  test "should update p42_menu_item_group" do
    patch :update, id: @p42_menu_item_group, p42_menu_item_group: { default_meal_modifier: @p42_menu_item_group.default_meal_modifier, name: @p42_menu_item_group.name }
    assert_redirected_to p42_menu_item_group_path(assigns(:p42_menu_item_group))
  end

  test "should destroy p42_menu_item_group" do
    assert_difference('P42::MenuItemGroup.count', -1) do
      delete :destroy, id: @p42_menu_item_group
    end

    assert_redirected_to p42_menu_item_groups_path
  end
end
