require "test_helper"

class PropertyControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get property_index_url
    assert_response :success
  end

  test "should get show" do
    get property_show_url
    assert_response :success
  end

  test "should get create" do
    get property_create_url
    assert_response :success
  end

  test "should get update" do
    get property_update_url
    assert_response :success
  end

  test "should get destroy" do
    get property_destroy_url
    assert_response :success
  end
end
