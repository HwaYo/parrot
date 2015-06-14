class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :logged_in?
  helper_method :current_user

protected
  def request_nr(record)
    RequestNrJob.new.async.perform(record)
  end

  def publish_event(key, object = {})
    object[:from] = 'web'
    object[:agent] = request.user_agent
    object[:uid] = current_user.try(:uid)
    object[:channel] = user_channel
    PublishEventJob.new.async.perform(key, object)
  end

private
  def logged_in?
    unless session[:user_id]
      flash[:error] = "로그인을 하셔야만 계속 진행할 수 있습니다. 로그인해주세요."
      redirect_to root_path
    end
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def user_channel
    if current_user
      current_user.channel
    else
      session[:channel]
    end
  end
end
