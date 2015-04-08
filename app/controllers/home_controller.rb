class HomeController < ApplicationController
  def index
    if current_user
      redirect_to records_path
    else
      render layout: "home_application"
    end
  end
end