class StatusController < ApplicationController
  def check
    render :json => {
      :status => 'ok',
      :version => Rails.application.version,
      :environment => Rails.env
    }
  end
end
