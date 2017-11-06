require 'rails_helper'

RSpec.describe "Signing Up", :type => :request do
  before(:each) do
    @first_name = "Bob"
    @last_name = "Smith"
    @email = "unused.email.for.testing@gmail.com"
    @password = "password"
  end

  describe "POST /api/users" do
    before(:each) do
      post "/api/users", {
        "user" => {
          "first_name" => @first_name,
          "last_name" => @last_name,
          "email" => @email,
          "password" => @password
        }
      }
    end

    it "returns a 201" do
      expect(response.status).to eq(201)
    end

    it "creates a new user" do
      expect(User.find_by(email: @email)).not_to be_nil
    end

    it "contains an auth token" do
      expect(!!response.body["authentication_token"])
    end
  end
end
