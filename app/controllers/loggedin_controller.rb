class LoggedinController < ApplicationController
  # these methods should only be accessible when signed in
  before_filter :authenticate_user!

  def index
  end
end
