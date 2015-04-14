class SessionsController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    user = User.find_by_provider_and_uid(auth["provider"], auth["uid"])

    if user.nil?
      user = User.create_with_omniauth(auth)
      create_bookmark!(user)
    end

    session[:user_id] = user.id
    redirect_to records_path
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "Signed out!"
  end

private
  def create_bookmark!(user)
    [
      { name: 'Important', color: '#e11d21' },
      { name: "Don't Understand", color: '#fbca04' },
      { name: 'Not Important', color: '#207de5' }
    ].each { |attribute| user.bookmarks.create!(attribute) }
  end
end
