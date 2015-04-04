class HomeController < ApplicationController
  def index
    render layout: "home_application"
  end
end