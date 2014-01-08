require 'test_helper'

class MyDropboxesControllerTest < ActionController::TestCase
  setup do
    @my_dropbox = my_dropboxes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:my_dropboxes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create my_dropbox" do
    assert_difference('MyDropbox.count') do
      post :create, my_dropbox: { access_token: @my_dropbox.access_token, account_name: @my_dropbox.account_name, app_key: @my_dropbox.app_key, app_secret: @my_dropbox.app_secret, authorized: @my_dropbox.authorized }
    end

    assert_redirected_to my_dropbox_path(assigns(:my_dropbox))
  end

  test "should show my_dropbox" do
    get :show, id: @my_dropbox
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @my_dropbox
    assert_response :success
  end

  test "should update my_dropbox" do
    patch :update, id: @my_dropbox, my_dropbox: { access_token: @my_dropbox.access_token, account_name: @my_dropbox.account_name, app_key: @my_dropbox.app_key, app_secret: @my_dropbox.app_secret, authorized: @my_dropbox.authorized }
    assert_redirected_to my_dropbox_path(assigns(:my_dropbox))
  end

  test "should destroy my_dropbox" do
    assert_difference('MyDropbox.count', -1) do
      delete :destroy, id: @my_dropbox
    end

    assert_redirected_to my_dropboxes_path
  end
end
