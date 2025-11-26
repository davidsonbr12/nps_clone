require "test_helper"

class CheersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get cheers_index_url
    assert_response :success
  end

  test "should get new" do
    get cheers_new_url
    assert_response :success
  end

  test "should get create" do
    get cheers_create_url
    assert_response :success
  end
end
