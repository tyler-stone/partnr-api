require 'rails_helper'

RSpec.describe "Posts", :type => :request do
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
    @role = build(:role)
    @post = build(:post)
    @role.project = @project
    @role.user = @user2
    @post.user = @user2
    # anybody else
    @user3 = build(:user3)
    @user3.confirmed_at = Time.zone.now
    @user3.save!

    @benchmark = build(:bmark)
    @benchmark.project = @project
    @benchmark.user = @user
    @post.bmark = @benchmark

    @project.save!
    @role.save!
    @benchmark.save!
    @post.save!
  end

  context "as the project owner" do
    before(:each) do
      login_as(@user, :scope => :user)
    end

    describe "GET /api/v1/posts/:id" do
      before(:each) do
        get "/api/v1/posts/#{@post.id}"
        @res = JSON.parse(response.body)
      end

      it "returns a 200" do
        expect(response.status).to eq(200)
      end

      it "returns a JSON Schema conforming post" do
        expect(@res).to match_json_schema(:full_post)
      end
    end

    describe "POST /api/v1/posts" do
      before(:each) do
        @title = "new post"
        @content = "new post content"
        post "/api/v1/posts", {
          "title" => @title,
          "content" => @content,
          "benchmark" => @benchmark.id
        }
        @res = JSON.parse(response.body)
      end

      it "returns a 201" do
        expect(response.status).to eq(201)
      end

      it "has all the proper attributes we gave it" do
        expect(@res["title"]).to eq(@title)
        expect(@res["content"]).to eq(@content)
        expect(@res["benchmark"]["id"]).to eq(@benchmark.id)
      end
    end

    describe "DELETE /api/v1/posts/:id" do
      before(:each) do
        @old_post_id = @post.id
        delete "/api/v1/posts/#{@post.id}"
      end

      it "returns a 204" do
        expect(response.status).to eq(204)
      end

      it "no longer exists" do
        get "/api/v1/posts/#{@old_post_id}"
        expect(response.status).to eq(404)
      end
    end

  end



  context "as the post author" do
    before(:each) do
      login_as(@user2, :scope => :user)
    end

    describe "GET /api/v1/posts/:id" do
      before(:each) do
        get "/api/v1/posts/#{@post.id}"
        @res = JSON.parse(response.body)
      end

      it "returns a 200" do
        expect(response.status).to eq(200)
      end

      it "returns a JSON Schema conforming post" do
        expect(@res).to match_json_schema(:full_post)
      end
    end

    describe "POST /api/v1/posts" do
      before(:each) do
        @title = "new post"
        @content = "new post content"
        post "/api/v1/posts", {
          "title" => @title,
          "content" => @content,
          "benchmark" => @benchmark.id
        }
        @res = JSON.parse(response.body)
      end

      it "returns a 201" do
        expect(response.status).to eq(201)
      end

      it "has all the proper attributes we gave it" do
        expect(@res["title"]).to eq(@title)
        expect(@res["content"]).to eq(@content)
        expect(@res["benchmark"]["id"]).to eq(@benchmark.id)
      end
    end

    describe "DELETE /api/v1/posts/:id" do
      before(:each) do
        @old_post_id = @post.id
        delete "/api/v1/posts/#{@old_post_id}"
      end

      it "returns a 204" do
        expect(response.status).to eq(204)
      end

      it "no longer exists" do
        get "/api/v1/posts/#{@old_post_id}"
        expect(response.status).to eq(404)
      end
    end


    describe "PUT /api/v1/posts/:id" do
      before(:each) do
        @new_title = "some different title than before"
        put "/api/v1/posts/#{@post.id}", {
          "title" => @new_title
        }
        @res = JSON.parse(response.body)
      end

      it "returns a 200" do
        expect(response.status).to eq(200)
      end

      it "changes the title" do
        expect(@res["title"]).to eq(@new_title)
      end
    end

  end

  context "as anybody else" do
    before(:each) do
      login_as(@user3, :scope => :user)
    end

    describe "POST /api/v1/posts" do
      before(:each) do
        @title = "new post"
        @content = "new post content"
        post "/api/v1/posts", {
          "title" => @title,
          "content" => @content,
          "benchmark" => @benchmark.id
        }
        @res = JSON.parse(response.body)
      end

      it "should return a 401" do
        expect(response.status).to eq(401)
      end
    end

    describe "PUT /api/v1/posts/:id" do
      before(:each) do
        @title = "new post"
        put "/api/v1/posts/#{@post.id}", {
          "title" => @title
        }
        @res = JSON.parse(response.body)
      end

      it "should return a 401" do
        expect(response.status).to eq(401)
      end
    end

    describe "DELETE /api/v1/posts/:id" do
      before(:each) do
        delete "/api/v1/posts/#{@post.id}"
      end

      it "should return a 401" do
        expect(response.status).to eq(401)
      end
    end

  end
end
