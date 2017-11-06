require 'rails_helper'

RSpec.describe StatusController, :type => :controller do

  describe "GET check" do
    before(:each) do
      get :check
      @res = JSON.parse(response.body)
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "reports the version number" do
      expect(@res["version"]).to eq(Rails.application.version)
    end

    it "reports 'status' = 'ok'" do
      expect(@res["status"]).to eq('ok')
    end
  end

end
