require 'rails_helper'

RSpec.describe Skillset, type: :model do
  before(:all) do
    @user = build(:user)
    @user.confirmed_at = Time.zone.now
    @user.save!

    @project = build(:good_project)
    @project.owner = @user.id
    @project.creator = @user.id
    @project.user_notifier = @user
    @project.save!

    @role = build(:role)
    @role.user = @user
    @role.project = @project
    @role.user_notifier = @user
    @role.save!

    @task = build(:task)
    @task.project = @project
    @task.user = @user
    @task.save!

    @task2 = build(:task)
    @task2.project = @project
    @task2.user = @user
    @task2.save!

    @category = create(:category)

    @skill = build(:skill)
    @skill2 = build(:skill2)
    @skill.category = @category
    @skill2.category = @category
    @skill.save!
    @skill2.save!

    # 2 = "complete"
    @task.update!({ categories: [@category],skills: [@skill, @skill2], status: 2 })
    @task2.update!({ categories: [@category], skills: [@skill2], status: 2 })
  end

  describe "the user's skillscore" do
    before(:all) do
      @skillset = @user.skillset
      @skillscore = @skillset.calculate
    end

    it "has 2 points for the category" do
      expect(@skillscore[:categories][@category.title]).to eq(2)
    end

    it "has 2 points for a skill and 1 point for the other" do
      expect(@skillscore[:skills][@skill.title]).to eq(1)
      expect(@skillscore[:skills][@skill2.title]).to eq(2)
    end
  end
end
