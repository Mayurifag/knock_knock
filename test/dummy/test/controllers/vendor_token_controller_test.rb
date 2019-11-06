# frozen_string_literal: true

require "test_helper"

class VendorTokenControllerTest < ActionController::TestCase
  def setup
    @vendor = vendors(:one)
  end

  test "responds with 422 if user does not exist" do
    post :create, params: {email: "wrong@example.net", password: ""}
    assert_response :unprocessable_entity
  end

  test "responds with 422 if password is invalid" do
    post :create, params: {email: @vendor.email, password: "wrong"}
    assert_response :unprocessable_entity
  end

  test "responds with 201" do
    post :create, params: {email: @vendor.email, password: "secret"}
    assert_response :created
  end
end
