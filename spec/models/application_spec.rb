require 'rails_helper'

RSpec.describe Application, :type => :model do
  before(:each) do
    @project = build(:good_project)
    @role = build(:role)
    @application = build(:application)
    @user = build(:user)
    @user.id = 1
    @user2 = build(:user2)
    @user2.id = 2
    @user3 = build(:user3)
    @user3.id = 3

    @project.owner = @user.id
    @role.project = @project
    @application.role = @role
    @application.user = @user2
    @application.project = @project

    @user.save
    @user2.save
    @user3.save
    @project.save
    @role.save
    @application.save
  end

  describe "#has_update_permissions" do
    it "returns true for the applicant" do
      expect(@application.has_update_permissions(@user2)).to be(true)
    end

    it "returns false for the project owner" do
      expect(@application.has_update_permissions(@user)).to be(false)
    end

    it "returns false for anybody else" do
      expect(@application.has_update_permissions(@user3)).to be(false)
    end
  end

  describe "#has_accept_permissions" do
    it "returns false for the applicant" do
      expect(@application.has_accept_permissions(@user2)).to be(false)
    end

    it "returns true for the project owner" do
      expect(@application.has_accept_permissions(@user)).to be(true)
    end

    it "returns false for anybody else" do
      expect(@application.has_accept_permissions(@user3)).to be(false)
    end
  end

  describe "#has_destroy_permissions" do
    it "returns true for the applicant" do
      expect(@application.has_destroy_permissions(@user2)).to be(true)
    end

    it "returns true for the project owner" do
      expect(@application.has_destroy_permissions(@user)).to be(true)
    end

    it "returns false for anybody else" do
      expect(@application.has_destroy_permissions(@user3)).to be(false)
    end
  end

end
