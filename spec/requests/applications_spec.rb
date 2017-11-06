require 'rails_helper'

RSpec.describe "Applications", :type => :request do
  before(:each) do
    @role = build(:role)
    @role2 = build(:role2)

    @application = build(:application)
    @application2 = build(:application2)

    @user = build(:user)
    @user2 = build(:user2)
    @user3 = build(:user3)
    @user.confirmed_at = Time.zone.now
    @user2.confirmed_at = Time.zone.now
    @user3.confirmed_at = Time.zone.now
    @user.save!
    @user2.save!
    @user3.save!

    @project = create(:good_project)
    @project2 = create(:good_project2)

    @project.owner = @user.id
    @project2.owner = @user2.id

    @role.project = @project
    @role2.project = @project2
    @role.user = @user
    @role2.user = nil

    @application.role = @role
    @application.user = @user2
    @application.project = @project
    @application2.role = @role2
    @application2.user = @user3
    @application2.project = @project2

    @project.save!
    @project2.save!
    @role.save!
    @role2.save!
    @application.save!
    @application2.save!
  end

  describe "GET /api/v1/applications" do
    it "returns a 200" do
      get "/api/v1/applications"
      expect(response.status).to eq(200)
    end

    context "without any query params" do
      before(:each) do
        get "/api/v1/applications"
        @res = JSON.parse(response.body)
      end

      it "returns two applications" do
        expect(@res.length).to eq(2)
      end

      it "matches the JSON schema" do
        expect(@res[0]).to match_json_schema(:search_application)
        expect(@res[1]).to match_json_schema(:search_application)
      end
    end

    context "with a supplied user id" do
      before(:each) do
        get "/api/v1/applications", user: @user2.id
        @res = JSON.parse(response.body)
      end

      it "returns one application" do
        expect(@res.length).to eq(1)
      end

      it "matches the JSON schema" do
        expect(@res[0]).to match_json_schema(:search_application)
      end
    end

    context "with a supplied project id" do
      before(:each) do
        get "/api/v1/applications", project: @project.id
        @res = JSON.parse(response.body)
      end

      it "returns one application" do
        expect(@res.length).to eq(1)
      end

      it "matches the JSON schema" do
        expect(@res[0]).to match_json_schema(:search_application)
      end
    end

    context "with a supplied role id" do
      before(:each) do
        get "/api/v1/applications", role: @role2.id
        @res = JSON.parse(response.body)
      end

      it "returns one application" do
        expect(@res.length).to eq(1)
      end

      it "matches the JSON schema" do
        expect(@res[0]).to match_json_schema(:search_application)
      end
    end
  end

  describe "GET /api/v1/applications/:id" do
    context "bad request" do
      before(:each) do
        get "/api/v1/applications/0"
        @res = JSON.parse(response.body)
      end

      it "returns a 404" do
        expect(response.status).to eq(404)
      end
    end

    context "good request" do
      before(:each) do
        get "/api/v1/applications/#{@application.id}"
        @res = JSON.parse(response.body)
      end

      it "returns a 200" do
        expect(response.status).to eq(200)
      end

      it "returns JSON Schema conforming application" do
        expect(@res).to match_json_schema(:full_application)
      end
    end
  end


  context "unauthenticated user" do
    describe "POST /api/v1/applications" do
      before(:each) do
        post "/api/v1/applications", {
          "role" => @role.id
        }
        @res = JSON.parse(response.body)
      end

      it "returns a 401" do
        expect(response.status).to eq(401)
      end
    end

    describe "PUT /api/v1/applications/:id" do
      before(:each) do
        put "/api/v1/applications/#{@application.id}", {
          "status" => "accepted"
        }
      end

      it "returns a 401" do
        expect(response.status).to eq(401)
      end
    end

    describe "DELETE /api/v1/applications/:id" do
      before(:each) do
        delete "/api/v1/applications/#{@application.id}"
      end

      it "returns a 401" do
        expect(response.status).to eq(401)
      end
    end
  end


  context "authenticated user" do
    before(:each) do
      login_as(@user3, :scope => :user)
    end

    describe "POST /api/v1/applications" do

      context "good request" do
        before(:each) do
          post "/api/v1/applications", {
            "role" => @role.id
          }
          @res = JSON.parse(response.body)
        end

        it "returns a 201" do
          expect(response.status).to eq(201)
        end

        it "has all the proper attributes we gave it" do
          expect(@res["status"]).to eq("pending")
        end

        it "returns a JSON Schema conforming application" do
          expect(@res).to match_json_schema(:full_application)
        end
      end


      context "bad request" do
        before(:each) do
          post "/api/v1/applications", {
            "role" => 0
          }
          @res = JSON.parse(response.body)
        end

        it "returns a 400" do
          expect(response.status).to eq(400)
        end
      end

      context "already on project" do
        before(:each) do
          @role.user = @user3
          @role.save

          post "/api/v1/applications", {
            "role" => @role.id
          }
        end

        it "returns a 400" do
          expect(response.status).to eq(400)
        end
      end
    end

    describe "PUT /api/v1/applications/:id" do
      context "as the project owner" do
        before(:each) do
          @project.owner = @user3.id
          @project.save
        end

        context "status becomes accepted" do
          before(:each) do
            @role.user = nil
            @role.save
            put "/api/v1/applications/#{@application.id}", {
              "status" => "accepted"
            }
            @res = JSON.parse(response.body)
          end

          after(:each) do
            @role.user = @user
            @role.save
          end

          it "returns a 200" do
            expect(response.status).to eq(200)
          end

          it "returns a JSON schema matching application" do
            expect(@res).to match_json_schema(:full_application)
          end

          it "changes to accepted" do
            expect(@res["status"]).to eq("accepted")
          end

          it "fills the role with the applicant" do
            get "/api/v1/roles/#{@application.role.id}"
            res = JSON.parse(response.body)
            expect(@application.user.id).to eq(res["user"]["id"])
          end
        end

        context "status becomes pending" do
          before(:each) do
            @application.status = "accepted"
            @application.save
            put "/api/v1/applications/#{@application.id}", {
              "status" => "pending"
            }
            @res = JSON.parse(response.body)
          end

          it "returns a 401" do
            expect(response.status).to eq(401)
          end
        end

      end

      context "as a role applicant" do
        before(:each) do
          @application.user = @user3
          @application.save
        end

        context "status becomes accepted" do
          before(:each) do
            put "/api/v1/applications/#{@application.id}", {
              "status" => "accepted"
            }
            @res = JSON.parse(response.body)
          end

          it "returns a 401" do
            expect(response.status).to eq(401)
          end
        end

      end

      context "as anybody else" do
        before(:each) do
          @application.user = @user2
          @project.owner = @user.id
          @application.save
          @project.save
        end

        it "doesn't allow any change" do
          put "/api/v1/applications/#{@application.id}", {
            "status" => "pending"
          }
          expect(response.status).to eq(401)

          put "/api/v1/applications/#{@application.id}", {
            "status" => "accepted"
          }
          expect(response.status).to eq(401)
        end
      end
    end
  end

end
