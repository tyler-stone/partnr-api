require 'rails_helper'

RSpec.describe User, :type => :model do
  before(:each) do
    @user = build(:user)
    @user2 = build(:user2)
    @users = [@user, @user2]
  end

  describe "#name" do
    it "returns the first and last name of the user" do
      name = @user.name
      expected = @user.first_name + " " + @user.last_name

      expect(name).to eq(expected)
    end
  end

  describe "#mailboxer_email" do
    it "returns the email of the user" do
      email = @user.mailboxer_email([])
      expected = @user.email

      expect(email).to eq(expected)
    end
  end

  describe "#json_conversations" do
    it "returns an empty list if there are no conversations" do
      expect(@user.json_conversations).to eq []
    end

    it "returns an array of participants and ids for conversations" do
      @user2.send_message(@user, "body", "subject")
      conv_id = @user2.mailbox.conversations.all[0].id
      convs = [{
        "participants"=>[{
          "name" => @user2.name,
          "email" => @user2.email
        }],
        "id"=>conv_id
      }]

      expect(@user.json_conversations).to eq convs
    end
  end

  describe "#get_conv" do
    it "returns nil if given wrong params" do
      expect(@user.get_conv(nil)).to eq(nil)
    end

    it "returns nil if the conversation doesn't exist" do
      expect(@user.get_conv(-1)).to eq(nil)
    end

    it "returns an array of message/sender objects" do
      @user.send_message(@user2, "body", "subject")
      conv = @user.mailbox.conversations.all[0]

      expect(@user.get_conv(conv.id)).to eq([{"message" => conv.last_message.body, "sender" => @user.name}])
    end
  end

end
