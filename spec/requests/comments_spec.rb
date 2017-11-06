require 'rails_helper'

RSpec.describe "Comments", :type => :request do
  before(:each) do
    # owner
    @user = build(:user)
    @user.confirmed_at = Time.zone.now
    @user.save!
    @project = build(:good_project)
    @project.owner = @user.id
    # author
    @user2 = build(:user2)
    @user2.confirmed_at = Time.zone.now
    @user2.save!
    @comment = build(:comment)
    @comment.project = @project
    @comment.user = @user2
    # anybody else
    @user3 = build(:user3)
    @user3.confirmed_at = Time.zone.now
    @user3.save!

    @project.save!
    @comment.save!
  end

  context "as the project owner" do
    before(:each) do
      login_as(@user, :scope => :user)
    end

    describe "GET /api/v1/comments/:id" do
      before(:each) do
        get "/api/v1/comments/#{@comment.id}"
        @res = JSON.parse(response.body)
      end

      it "returns a 200" do
        expect(response.status).to eq(200)
      end

      it "returns a JSON Schema conforming comment" do
        expect(@res).to match_json_schema(:full_comment)
      end
    end

    describe "POST /api/v1/comments" do
      before(:each) do
        @content = "comment content"
        post "/api/v1/comments", {
          "content" => @content,
          "project" => @project.id
        }
        @res = JSON.parse(response.body)
      end

      it "returns a 201" do
        expect(response.status).to eq(201)
      end

      it "has all the proper attributes we gave it" do
        expect(@res["content"]).to eq(@content)
        expect(@res["user"]["id"]).to eq(@user.id)
      end
    end

    describe "PUT /api/v1/comments/:id" do
      before(:each) do
        @new_content = "new content"
        put "/api/v1/comments/#{@comment.id}", {
          "content" => @new_content
        }
      end

      it "returns a 401" do
        expect(response.status).to eq(401)
      end

      it "is unchanged" do
        expect(@comment.content).not_to eq(@new_content)
      end
    end

    describe "DELETE /api/v1/comments/:id" do
      before(:each) do
        @old_comment_id = @comment.id
        delete "/api/v1/comments/#{@comment.id}"
      end

      it "returns a 204" do
        expect(response.status).to eq(204)
      end

      it "no longer exists" do
        get "/api/v1/comments/#{@old_comment_id}"
        expect(response.status).to eq(404)
      end
    end
  end


  describe "as the comment author" do
    before(:each) do
      login_as(@user2, :scope => :user)
    end

    describe "GET /api/v1/comments/:id" do
      before(:each) do
        get "/api/v1/comments/#{@comment.id}"
        @res = JSON.parse(response.body)
      end

      it "returns a 200" do
        expect(response.status).to eq(200)
      end

      it "returns a JSON Schema conforming comment" do
        expect(@res).to match_json_schema(:full_comment)
      end
    end

    describe "POST /api/v1/comments" do
      before(:each) do
        @content = "new comment content"
        post "/api/v1/comments", {
          "content" => @content,
          "project" => @project.id
        }
        @res = JSON.parse(response.body)
      end

      it "returns a 201" do
        expect(response.status).to eq(201)
      end

      it "has all the proper attributes we gave it" do
        expect(@res["content"]).to eq(@content)
        expect(@res["user"]["id"]).to eq(@user2.id)
      end
    end

    describe "DELETE /api/v1/comments/:id" do
      before(:each) do
        @old_comment_id = @comment.id
        delete "/api/v1/comments/#{@old_comment_id}"
      end

      it "returns a 204" do
        expect(response.status).to eq(204)
      end

      it "no longer exists" do
        get "/api/v1/comments/#{@old_comment_id}"
        expect(response.status).to eq(404)
      end
    end


    describe "PUT /api/v1/comments/:id" do
      before(:each) do
        @new_content = "some different content than before"
        put "/api/v1/comments/#{@comment.id}", {
          "content" => @new_content
        }
        @res = JSON.parse(response.body)
      end

      it "returns a 200" do
        expect(response.status).to eq(200)
      end

      it "changes the content" do
        expect(@res["content"]).to eq(@new_content)
      end
    end
  end


  context "as anybody else" do
    before(:each) do
      login_as(@user3, :scope => :user)
    end

    describe "GET /api/v1/comments/:id" do
      before(:each) do
        get "/api/v1/comments/#{@comment.id}"
        @res = JSON.parse(response.body)
      end

      it "returns a 200" do
        expect(response.status).to eq(200)
      end

      it "returns a JSON Schema conforming comment" do
        expect(@res).to match_json_schema(:full_comment)
      end
    end

    describe "POST /api/v1/comments" do
      before(:each) do
        @content = "comment content"
        post "/api/v1/comments", {
          "content" => @content,
          "project" => @project.id
        }
        @res = JSON.parse(response.body)
      end

      it "returns a 201" do
        expect(response.status).to eq(201)
      end

      it "has all the proper attributes we gave it" do
        expect(@res["content"]).to eq(@content)
        expect(@res["user"]["id"]).to eq(@user3.id)
      end
    end

    describe "PUT /api/v1/comments/:id" do
      before(:each) do
        @new_content = "new content"
        put "/api/v1/comments/#{@comment.id}", {
          "content" => @new_content
        }
      end

      it "returns a 401" do
        expect(response.status).to eq(401)
      end

      it "is unchanged" do
        expect(@comment.content).not_to eq(@new_content)
      end
    end

    describe "DELETE /api/v1/comments/:id" do
      before(:each) do
        @old_comment_id = @comment.id
        delete "/api/v1/comments/#{@comment.id}"
      end

      it "returns a 401" do
        expect(response.status).to eq(401)
      end
    end
  end
end
