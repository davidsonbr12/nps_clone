require "test_helper"

class CheersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should get index" do
    sign_in users(:one)
    get cheers_url
    assert_response :success
  end

  test "should get new" do
    sign_in users(:one)
    get new_cheer_url
    assert_response :success
  end

  test "should get create" do
    sign_in users(:one)
    post cheers_url, params: { cheer: { content: "Great job!", recipient_id: users(:two).id } }
    assert_response :redirect
  end
end
