class PingController < ApplicationController
  skip_before_action :logged_in?
  def index
    render plain: "Pong", :status => 200
  end
end
