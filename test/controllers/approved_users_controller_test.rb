require 'test_helper'

class ApprovedUsersControllerTest < ActionController::TestCase
  setup do
    @approved_user = approved_users(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:approved_users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create approved_user" do
    assert_difference('ApprovedUser.count') do
      post :create, approved_user: { email: @approved_user.email, name: @approved_user.name }
    end

    assert_redirected_to approved_user_path(assigns(:approved_user))
  end

  test "should show approved_user" do
    get :show, id: @approved_user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @approved_user
    assert_response :success
  end

  test "should update approved_user" do
    patch :update, id: @approved_user, approved_user: { email: @approved_user.email, name: @approved_user.name }
    assert_redirected_to approved_user_path(assigns(:approved_user))
  end

  test "should destroy approved_user" do
    assert_difference('ApprovedUser.count', -1) do
      delete :destroy, id: @approved_user
    end

    assert_redirected_to approved_users_path
  end
end
