class Subscription < ActiveRecord::Base
  after_create :notify_slack

private
  def notify_slack
    SlackNotificationJob.new.async.perform("New subscription: #{self[:name]} / #{self[:email]}")
  end
end
