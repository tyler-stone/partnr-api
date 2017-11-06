require 'rails_helper'

RSpec.describe "Roles", :type => :request do
  before(:each) do
    @role = build(:role)
    @role2 = build(:role2)
    @categorized_role = build(:role2)
    @category = build(:category)
    @user = build(:user)
    @user2 = build(:user2)
    @user3 = build(:user3)
    @user.confirmed_at = Time.zone.now
    @user2.confirmed_at = Time.zone.now
    @user3.confirmed_at = Time.zone.now
    @user.save!
    @user2.save!
    @user3.save!
    @project = build(:good_project)
    @project.user_notifier = @user3
    @project.owner = @user3.id
    @project.creator = @user3.id
    @project.save!

    @role.project = @project
    @role2.project = @project
    @role.user = @user
    @role2.user = nil
    @categorized_role.category = @category
    @categorized_role.project = @project
    @categorized_role.user_notifier = @user3 
    @role.user_notifier = @user3
    @role2.user_notifier = @user3

    @categorized_role.save!
    @role.save!
    @role2.save!

  end

  describe "GET /api/v1/roles" do
    it "returns a 200" do
      get "/api/v1/roles"
      expect(response.status).to eq(200)
    end

    context "with a supplied category id" do 
      before(:each) do
        get "/api/v1/roles?category=#{@category.id}"
        @res = JSON.parse(response.body)
      end

      it "returns one roles" do
        expect(@res.length).to eq(1)
      end

      it "has the right category" do 
        expect(@res.first["category"]["id"]).to eq(@category.id)
      end
    end

    context "without a supplied project id" do
      before(:each) do
        get "/api/v1/roles?project=#{@project.id}"
        @res = JSON.parse(response.body)
      end

      it "returns two roles" do
        expect(@res.length).to eq(3)
      end

      it "matches the JSON schema" do
        expect(@res[0]).to match_json_schema(:search_role)
        expect(@res[1]).to match_json_schema(:search_role)
      end
    end

    context "with a supplied user id" do
      before(:each) do
        get "/api/v1/roles", user: @user.id
        @res = JSON.parse(response.body)
      end

      it "returns one role" do
        expect(@res.length).to eq(1)
      end

      it "matches the JSON schema" do
        expect(@res[0]).to match_json_schema(:search_role)
      end

      it "has a user with the supplied id" do
        expect(@res.all? { |r| r[:user] == @user.id })
      end
    end
  end

  describe "GET /api/v1/roles/:id" do
    context "bad request" do
      before(:each) do
        get "/api/v1/roles/0"
        @res = JSON.parse(response.body)
      end

      it "returns a 404" do
        expect(response.status).to eq(404)
      end
    end

    context "good request" do
      before(:each) do
        get "/api/v1/roles/#{@role.id}"
        @res = JSON.parse(response.body)
      end

      it "returns a 200" do
        expect(response.status).to eq(200)
      end

      it "returns JSON Schema conforming role" do
        expect(@res).to match_json_schema(:full_role)
      end
    end
  end


  context "unauthenticated user" do
    describe "POST /api/v1/roles" do
      before(:each) do
        post "/api/v1/roles", {
          "title" => "Some title",
          "project" => @project.id
        }
      end

      it "returns a 401" do
        expect(response.status).to eq(401)
      end
    end

    describe "PUT /api/v1/roles/:id" do
      before(:each) do
        put "/api/v1/roles/#{@role.id}", {
          "title" => "new title"
        }
      end

      it "returns a 401" do
        expect(response.status).to eq(401)
      end
    end

    describe "DELETE /api/v1/roles/:id" do
      before(:each) do
        delete "/api/v1/roles/#{@role.id}"
      end

      it "returns a 401" do
        expect(response.status).to eq(401)
      end
    end
  end


  context "authenticated user" do
    before(:each) do
      login_as(@user, :scope => :user)
    end

    describe "POST /api/v1/roles" do

      context "good request" do
        before(:each) do
          @title = "Some title"
          @proj = @project.id
          post "/api/v1/roles", {
            "title" => @title,
            "project" => @proj
          }
          @res = JSON.parse(response.body)
        end

        it "returns a 201" do
          expect(response.status).to eq(201)
        end

        it "has all the proper attributes we gave it" do
          expect(@res["title"]).to eq(@title)
          expect(@res["id"]).to eq(Role.last.id)
          expect(@res["user"]).to eq(nil)
        end

        it "returns a JSON Schema conforming role" do
          expect(@res).to match_json_schema(:full_role)
        end
      end


      context "bad request" do
        before(:each) do
          @title = "Some title"
          post "/api/v1/roles", {
            "title" => @title
          }
        end

        it "returns a 400" do
          expect(response.status).to eq(400)
        end
      end
    end

    describe "PUT /api/v1/roles/:id" do
      context "user does not have permissions" do
        before(:each) do
          put "/api/v1/roles/#{@role2.id}", {
            "title" => "the new title for this role"
          }
        end

        it "returns a 401" do
          expect(response.status).to eq(401)
        end
      end

      context "user has proper permissions to update 'user' field" do
        before(:each) do
          @project.owner = @user.id
          @project.save
          @role.user = nil
          @role.save
          put "/api/v1/roles/#{@role.id}", {
            "user" => @user.id
          }
          @res = JSON.parse(response.body)
        end

        it "returns a 200" do
          expect(response.status).to eq(200)
        end

        it "returns the updated role" do
          expect(@res["user"]["id"]).to eq(@user.id)
        end

        it "returns a JSON Schema conforming role" do
          expect(@res).to match_json_schema(:full_role)
        end
      end

      context "user does not have proper permissions to update 'user' field" do
        before(:each) do
          @project.owner = @user2
          @project.save
          put "/api/v1/roles/#{@role.id}", {
            "user" => @user2.id
          }
          @res = JSON.parse(response.body)
        end

        it "returns a 401" do
          expect(response.status).to eq(401)
        end
      end

      context "user has proper permissions to update the 'title' field" do
        before(:each) do
          @role.user = @user
          @role.save
          @title = "the new title for this role"
          put "/api/v1/roles/#{@role.id}", {
            "title" => @title
          }
          @res = JSON.parse(response.body)
        end

        it "returns a 200" do
          expect(response.status).to eq(200)
        end

        it "returns the updated role" do
          expect(@res["title"]).to eq(@title)
        end

        it "returns a JSON Schema conforming role" do
          expect(@res).to match_json_schema(:full_role)
        end
      end

      context "user does not have proper permissions to update 'user' field" do
        before(:each) do
          @project.owner = @user2.id
          @project.save
          @role2.user = @user2
          @role2.save
          put "/api/v1/roles/#{@role2.id}", {
            "user" => @user.id
          }
          @res = JSON.parse(response.body)
        end

        it "returns a 401" do
          expect(response.status).to eq(401)
        end
      end

    end

    describe "DELETE /api/v1/roles/:id" do
      context "user does not have permissions" do
        before(:each) do
          @project.owner = @user2

          @project.save
          delete "/api/v1/roles/#{@role2.id}"
        end

        it "returns a 401" do
          expect(response.status).to eq(401)
        end
      end

      context "user has proper permissions" do
        before(:each) do
          @role.project = @project
          @project.owner = @user.id
          @project.save
          @role.save
          delete "/api/v1/roles/#{@role.id}"
        end

        it "returns a 204" do
          expect(response.status).to eq(204)
        end

        it "deletes the role" do
          get "/api/v1/roles/#{@role.id}"
          expect(response.status).to eq(404)
        end
      end
    end
  end

  describe "removing a user from a role" do
    context "as the project owner" do
      before(:each) do
        login_as(@user3, :scope => :user)
        put "/api/v1/roles/#{@role.id}", {
          "user" => nil
        }
      end

      it "returns a 200" do
        expect(response.status).to eq(200)
      end

      it "makes the role empty" do
        expect @role.user.nil?
      end
    end

    context "as the user in the role" do
      before(:each) do
        login_as(@user, :scope => :user)
        put "/api/v1/roles/#{@role.id}", {
          "user" => nil
        }
      end

      it "returns a 200" do
        expect(response.status).to eq(200)
      end

      it "makes the role empty" do
        expect @role.user.nil?
      end
    end

    context "as anybody else" do
      before(:each) do
        login_as(@user2, :scope => :user)
        put "/api/v1/roles/#{@role.id}", {
          "user" => nil
        }
      end

      it "returns a 401" do
        expect(response.status).to eq(401)
      end

      it "does not make the role empty" do
        expect !@role.user.nil?
      end
    end
  end
end
