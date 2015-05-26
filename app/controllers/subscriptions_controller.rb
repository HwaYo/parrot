class SubscriptionsController < ApplicationController
  skip_before_action :logged_in?
  def create
    Subscription.create!(subscription_params)
    redirect_to root_path
  end

private
  def subscription_params
    params.require(:subscription).permit(:name, :email, :message)
  end
end