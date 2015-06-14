class HomeController < ApplicationController
  skip_before_action :logged_in?
  before_action :capture_channel

  def index
    if current_user
      redirect_to records_path
    else
      publish_event 'landing'
      render layout: "home_application"
    end
  end

private
  def capture_channel
    channel = request.query_parameters["share"]
    if channel.present?
      session[:channel] = channel
      redirect_to "#{request.path}?#{request.query_parameters.except(:share).to_query}"
    end
  end
end