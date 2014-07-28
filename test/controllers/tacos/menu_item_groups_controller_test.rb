require 'test_helper'

class Tacos::MenuItemGroupsControllerTest < ActionController::TestCase
  setup do
    @tacos_menu_item_group = tacos_menu_item_groups(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tacos_menu_item_groups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tacos_menu_item_group" do
    assert_difference('Tacos::MenuItemGroup.count') do
      post :create, tacos_menu_item_group: { default_meal_modifier: @tacos_menu_item_group.default_meal_modifier, name: @tacos_menu_item_group.name }
    end

    assert_redirected_to tacos_menu_item_group_path(assigns(:tacos_menu_item_group))
  end

  test "should show tacos_menu_item_group" do
    get :show, id: @tacos_menu_item_group
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tacos_menu_item_group
    assert_response :success
  end

  test "should update tacos_menu_item_group" do
    patch :update, id: @tacos_menu_item_group, tacos_menu_item_group: { default_meal_modifier: @tacos_menu_item_group.default_meal_modifier, name: @tacos_menu_item_group.name }
    assert_redirected_to tacos_menu_item_group_path(assigns(:tacos_menu_item_group))
  end

  test "should destroy tacos_menu_item_group" do
    assert_difference('Tacos::MenuItemGroup.count', -1) do
      delete :destroy, id: @tacos_menu_item_group
    end

    assert_redirected_to tacos_menu_item_groups_path
  end
end
