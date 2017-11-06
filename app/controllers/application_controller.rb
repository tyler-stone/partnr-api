class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_signup_parameters, if: :devise_controller?

  protected

  def configure_signup_parameters
    devise_parameter_sanitizer.for(:sign_up) { |i| i.permit(:first_name, :last_name, :email, :password) }
  end

  private

  def after_sign_in_path_for(res)
    "/api/v1/users/#{res.id}"
  end

  def after_sign_up_path_for(res)
    root_path
  end

  def after_sign_out_path_for(res_or_scope)
    root_path
  end
end
