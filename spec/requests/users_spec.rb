require 'rails_helper'

RSpec.describe "Users", :type => :request do
  before(:each) do
    @user = build(:user)
    @user.confirmed_at = Time.zone.now
    @user.save!
  end

  describe "PUT /api/v1/users" do
    context "unauthenticated user" do
      before(:each) do
        put "/api/v1/users"
        @res = JSON.parse(response.body)
      end

      it "returns a 401" do
        expect(response.status).to eq(401)
      end
    end

    context "authenticated user" do
      before(:each) do
        @old_first_name = @user.first_name
        @old_last_name = @user.last_name
        @new_first_name = "this is new"
        @new_last_name = "this is also new"

        login_as(@user, :scope => :user)
        put "/api/v1/users", {
          "first_name" => @new_first_name,
          "last_name" => @new_last_name
        }
        logout(@user)
        @res = JSON.parse(response.body)
      end

      after(:each) do
      end

      it "returns a 200" do
        expect(response.status).to eq(200)
      end

      it "changes the first_name" do
        expect(@res["first_name"]).not_to eq(@old_first_name)
        expect(@res["first_name"]).to eq(@new_first_name)
      end

      it "changes the last_name" do
        expect(@res["last_name"]).not_to eq(@old_last_name)
        expect(@res["last_name"]).to eq(@new_last_name)
      end
    end
  end
end
