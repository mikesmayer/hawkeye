require 'test_helper'

class P42::RevenueGroupsControllerTest < ActionController::TestCase
  setup do
    @p42_revenue_group = p42_revenue_groups(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:p42_revenue_groups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create p42_revenue_group" do
    assert_difference('P42::RevenueGroup.count') do
      post :create, p42_revenue_group: { name: @p42_revenue_group.name }
    end

    assert_redirected_to p42_revenue_group_path(assigns(:p42_revenue_group))
  end

  test "should show p42_revenue_group" do
    get :show, id: @p42_revenue_group
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @p42_revenue_group
    assert_response :success
  end

  test "should update p42_revenue_group" do
    patch :update, id: @p42_revenue_group, p42_revenue_group: { name: @p42_revenue_group.name }
    assert_redirected_to p42_revenue_group_path(assigns(:p42_revenue_group))
  end

  test "should destroy p42_revenue_group" do
    assert_difference('P42::RevenueGroup.count', -1) do
      delete :destroy, id: @p42_revenue_group
    end

    assert_redirected_to p42_revenue_groups_path
  end
end
