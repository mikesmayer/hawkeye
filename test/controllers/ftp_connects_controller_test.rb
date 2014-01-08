require 'test_helper'

class FtpConnectsControllerTest < ActionController::TestCase
  setup do
    @ftp_connect = ftp_connects(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ftp_connects)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ftp_connect" do
    assert_difference('FtpConnect.count') do
      post :create, ftp_connect: { password: @ftp_connect.password, server: @ftp_connect.server, username: @ftp_connect.username }
    end

    assert_redirected_to ftp_connect_path(assigns(:ftp_connect))
  end

  test "should show ftp_connect" do
    get :show, id: @ftp_connect
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ftp_connect
    assert_response :success
  end

  test "should update ftp_connect" do
    patch :update, id: @ftp_connect, ftp_connect: { password: @ftp_connect.password, server: @ftp_connect.server, username: @ftp_connect.username }
    assert_redirected_to ftp_connect_path(assigns(:ftp_connect))
  end

  test "should destroy ftp_connect" do
    assert_difference('FtpConnect.count', -1) do
      delete :destroy, id: @ftp_connect
    end

    assert_redirected_to ftp_connects_path
  end
end
