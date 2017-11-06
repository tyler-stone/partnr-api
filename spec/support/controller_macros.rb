module ControllerMacros
  def login_user
    before(:each) do
      @request.env["devise_mapping"] = Devise.mappings[:user]
      @user = FactoryGirl.build(:user)
      @user.confirmed_at = Time.zone.now
      @user.save
      sign_in @user
    end
  end
end
