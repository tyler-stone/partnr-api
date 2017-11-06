class RegistrationsController < Devise::RegistrationsController
  alias :super_create :create
  respond_to :json
  before_action :set_default_response_format

  def new
    render :json => {
      'csrfParam' => request_forgery_protection_token,
      'csrfToken' => form_authenticity_token
    }
  end

  def create
    super_create
  end

  protected

  def set_default_response_format
      request.format = :json
  end

  def sign_up(resource_name, resource)
    true
  end
end
