require 'test_helper'

class OneTimeDonationsControllerTest < ActionController::TestCase
  setup do
    @one_time_donation = one_time_donations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:one_time_donations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create one_time_donation" do
    assert_difference('OneTimeDonation.count') do
      post :create, one_time_donation: { amount: @one_time_donation.amount, deposit_date: @one_time_donation.deposit_date, description: @one_time_donation.description, meals: @one_time_donation.meals, restaurant_id: @one_time_donation.restaurant_id }
    end

    assert_redirected_to one_time_donation_path(assigns(:one_time_donation))
  end

  test "should show one_time_donation" do
    get :show, id: @one_time_donation
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @one_time_donation
    assert_response :success
  end

  test "should update one_time_donation" do
    patch :update, id: @one_time_donation, one_time_donation: { amount: @one_time_donation.amount, deposit_date: @one_time_donation.deposit_date, description: @one_time_donation.description, meals: @one_time_donation.meals, restaurant_id: @one_time_donation.restaurant_id }
    assert_redirected_to one_time_donation_path(assigns(:one_time_donation))
  end

  test "should destroy one_time_donation" do
    assert_difference('OneTimeDonation.count', -1) do
      delete :destroy, id: @one_time_donation
    end

    assert_redirected_to one_time_donations_path
  end
end
