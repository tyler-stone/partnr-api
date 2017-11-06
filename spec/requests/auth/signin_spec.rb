require 'rails_helper'

RSpec.describe "Signing In", :type => :request do
  before(:each) do
    @user = build(:user)
    @user.confirmed_at = Time.zone.now
    @user.save
  end

  describe "POST /api/users/sign_in" do
    before(:each) do
      post "/api/users/sign_in", {
        "user" => {
          "email" => @user.email,
          "password" => @user.password
        }
      }
      @res = JSON.parse(response.body)
    end

    it "returns a 200" do
      expect(response.status).to eq(200)
    end

    it "should have a last_sign_in_at property" do
      expect(@res.has_key? 'last_sign_in_at').to be true
    end

    it "should include an auth token" do
      expect(@res['user']['authentication_token']).not_to be_nil
    end
  end
end
