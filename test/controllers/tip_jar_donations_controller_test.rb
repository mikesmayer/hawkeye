require 'test_helper'

class TipJarDonationsControllerTest < ActionController::TestCase
  setup do
    @tip_jar_donation = tip_jar_donations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tip_jar_donations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tip_jar_donation" do
    assert_difference('TipJarDonation.count') do
      post :create, tip_jar_donation: { amount: @tip_jar_donation.amount, deposit_date: @tip_jar_donation.deposit_date, meals: @tip_jar_donation.meals, restaurant_id: @tip_jar_donation.restaurant_id }
    end

    assert_redirected_to tip_jar_donation_path(assigns(:tip_jar_donation))
  end

  test "should show tip_jar_donation" do
    get :show, id: @tip_jar_donation
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tip_jar_donation
    assert_response :success
  end

  test "should update tip_jar_donation" do
    patch :update, id: @tip_jar_donation, tip_jar_donation: { amount: @tip_jar_donation.amount, deposit_date: @tip_jar_donation.deposit_date, meals: @tip_jar_donation.meals, restaurant_id: @tip_jar_donation.restaurant_id }
    assert_redirected_to tip_jar_donation_path(assigns(:tip_jar_donation))
  end

  test "should destroy tip_jar_donation" do
    assert_difference('TipJarDonation.count', -1) do
      delete :destroy, id: @tip_jar_donation
    end

    assert_redirected_to tip_jar_donations_path
  end
end
