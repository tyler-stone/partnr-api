module V1::Helpers::ValidationHelper
  def warden
    env['warden']
  end

  def authenticated
    return true if warden.authenticated?
    params[:access_token] && @user = User.find_by_authentication_token(params[:access_token])
    if request.referer && URI(request.referer).query
      referer_params = CGI::parse(URI(request.referer).query)
      referer_params['confirmation_token'] && @user = User.find_by(confirmation_token: referer_params['confirmation_token'])
    end
  end

  def authenticated_user
    error!("You need to be logged in to do that", 401) unless authenticated
  end

  def current_user
    warden.user || @user
  end

  def dead_activity?(act)
    act.trackable_type.constantize.find_by(id: act.trackable_id).nil?
  end
end
