class SessionsController < Devise::SessionsController
  alias :super_destroy :destroy
  rescue_from ActionController::InvalidAuthenticityToken, :with => :check_csrf_token

  respond_to :json
  prepend_before_filter :set_default_response_format
  prepend_before_filter :check_post_params, only: :create

  def new
    render :json => {
      'csrfParam' => request_forgery_protection_token,
      'csrfToken' => form_authenticity_token
    }
  end

  def create
    check_post_params

    resource = User.find_for_database_authentication(:email => params[:user][:email])
    return invalid_login_attempt unless resource

    if resource.valid_password?(params[:user][:password])
      self.resource = warden.authenticate!({
        scope: :user
      })
      sign_in(:resource, resource)
      last_sign_in = resource.last_sign_in_at
      render :json => {
        'user' => resource.serializable_hash,
        'last_sign_in_at' => last_sign_in
      }
    else
      warden.custom_failure!
      render :json=> {:error => "That email/password does not match our records."}, :status => 401
    end

  end

  def destroy
    super_destroy
  end

  protected

  def set_default_response_format
      request.format = :json
  end

  # Devise method, only changes what it responds with
  def require_no_authentication
    assert_is_devise_resource!
    return unless is_navigational_format?
    no_input = devise_mapping.no_input_strategies

    authenticated = if no_input.present?
      args = no_input.dup.push scope: resource_name
      warden.authenticate?(*args)
    else
      warden.authenticated?(resource_name)
    end

    if authenticated && resource = warden.user(resource_name)
      render :json => {
        "error" => I18n.t("devise.failure.already_authenticated"),
        "user" => resource.serializable_hash,
        "csrfParam" => request_forgery_protection_token,
        "csrfToken" => form_authenticity_token
      }
    end
  end

  private

  def check_csrf_token
    render json: {
      error: 'Missing required header: X-CSRF-Token',
      status: 400
    }, status: 400
  end

  def check_post_params
    user = params[:user]
    if user.nil? || ( user[:email].nil? || user[:password].nil? )
      render json: {
        error: '{ user : { email : <email>, password : <password> } } format required for sign in',
        status: 400
      }, status: 400
    end
  end

  def invalid_login_attempt
    render :json=> {:error => "There is no user with that email."}, :status => 400
  end
end
