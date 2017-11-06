require 'rails_helper'

RSpec.describe "Benchmarks", :type => :request do
  before(:each) do
    @benchmark = build(:bmark)
    @benchmark2 = build(:bmark2)
    @benchmark3 = build(:bmark3)
    @benchmark4 = build(:bmark4)

    # owner/creator
    @user = build(:user)
    @user.confirmed_at = Time.zone.now
    @user.save!
    # participant
    @user2 = create(:user2)
    @user2.confirmed_at = Time.zone.now
    @user2.save!
    @role = build(:role)
    # anybody else
    @user3 = create(:user3)
    @user3.confirmed_at = Time.zone.now
    @user3.save!
    @project = create(:good_project)

    @benchmark.user = @user
    @benchmark2.user = @user
    @benchmark3.user = @user
    @benchmark4.user = @user

    @benchmark.project = @project
    @benchmark2.project = @project
    @benchmark3.project = @project
    @benchmark4.project = @project

    @role.user = @user2
    @role.project = @project

    @project.owner = @user.id

    @benchmark.save!
    @benchmark2.save!
    @benchmark3.save!
    @benchmark4.save!
    @project.save!
    @role.save!
  end

  context "as the project owner" do
    before(:each) do
      login_as(@user, :scope => :user)
    end

    describe "GET /api/v1/benchmarks/:id" do
      before(:each) do
        get "/api/v1/benchmarks/#{@benchmark.id}"
        @res = JSON.parse(response.body)
      end

      it "returns a 200" do
        expect(response.status).to eq(200)
      end

      it "returns a JSON Schema conforming benchmark" do
        expect(@res).to match_json_schema(:full_benchmark)
      end
    end

    describe "POST /api/v1/benchmarks" do
      before(:each) do
        @title = "new benchmark"
        post "/api/v1/benchmarks", {
          "title" => @title,
          "project" => @project.id
        }
        @res = JSON.parse(response.body)
      end

      it "returns a 201" do
        expect(response.status).to eq(201)
      end

      it "has all the proper attributes we gave it" do
        expect(@res["title"]).to eq(@title)
      end
    end

  end

  context "as a project participant" do
  end

  context "as anybody else" do
    before(:each) do
      login_as(@user3, :scope => :user)
    end

    describe "POST /api/v1/benchmarks" do
      before(:each) do
        @title = "new benchmark"
        post "/api/v1/benchmarks", {
          "title" => @title,
          "project" => @project.id
        }
        @res = JSON.parse(response.body)
      end

      it "should return a 401" do
        expect(response.status).to eq(401)
      end
    end

  end
end
