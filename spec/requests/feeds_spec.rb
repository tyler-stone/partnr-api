require 'rails_helper'

RSpec.describe "Feeds", :type => :request do
  before(:each) do
    @user = build(:user)
    @user.confirmed_at = Time.zone.now
    @user.save!

    @user2 = build(:user2)
    @user2.confirmed_at = Time.zone.now
    @user2.save!

    Connection.create!({
      user: @user,
      connection: @user2
    })

    @project = build(:good_project)
    @project.owner = @user.id
    @project.user_notifier = @user
    @project.save!

    @project.create_activity key: 'activity.project.started', owner: @user
    @project.create_activity key: 'activity.project.status_change', owner: @user
    @project.create_activity key: 'activity.project.status_change', owner: @user
    @project.create_activity key: 'activity.project.status_change', owner: @user
  end

  context "as a logged in user" do
    before(:each) do
      login_as(@user2, :scope => :user)
    end

    after(:each) do
      logout(@user2)
    end

    describe "GET /api/v1/feeds" do
      before(:each) do
        get "/api/v1/feeds"
        @res = JSON.parse(response.body)
      end

      it "should return a 200" do
        expect(response.status).to eq(200)
      end

      it "should return objects sorted by latest created_at date" do
        # highest ID should return the same thing, so let's sort by that
        sorted = @res.sort_by { |a| -a["id"] }
        sorted.each_with_index { |v, idx| expect(sorted[idx]["sent_at"]).to(eq(@res[idx]["sent_at"])) }
      end
    end
  end

  context "as an unauthorized user" do
    describe "GET /api/v1/feeds" do
      before(:each) do
        get "/api/v1/feeds"
        @res = JSON.parse(response.body)
      end

      it "should return a 401" do
        expect(response.status).to eq(401)
      end
    end
  end
end
