class AuthFailureRedirector < Devise::FailureApp

  def redirect_url(res)
    "/api/v1/users/#{res.id}"
  end

  def respond
    root_path
  end
end
