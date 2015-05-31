class SessionsController < ApplicationController
  skip_before_action :logged_in?

  def create
    auth = request.env["omniauth.auth"]
    user = User.find_by_provider_and_uid(auth["provider"], auth["uid"])

    if user.nil?
      user = User.create_with_omniauth(auth)
    end

    session[:user_id] = user.id

    publish_event('logged_in')

    redirect_to records_path
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "Signed out!"
  end
end
