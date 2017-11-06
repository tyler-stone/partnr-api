require 'rails_helper'

RSpec.describe Project, :type => :model do
  before(:each) do
    @project = build(:project)
    @user = build(:user)
    @user2 = build(:user2)
    @user.id = 1
    @user2.id = 2
    @project.owner = @user.id
  end

  describe "#has_admin_permissions" do
    it "fails if it isn't given a user" do
      expect(@project.has_admin_permissions(4)).to be false
    end

    it "fails if the user isn't the owner" do
      expect(@project.has_admin_permissions(@user2)).to be false
    end

    it "passes if the user is the owner" do
      expect(@project.has_admin_permissions(@user)).to be true
    end
  end
end
