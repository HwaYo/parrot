class SlackNotificationJob
  include SuckerPunch::Job

  WEBHOOK_URL = "https://hooks.slack.com/services/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".freeze

  def initialize
    @notifier = Slack::Notifier.new WEBHOOK_URL
  end

  def perform(msg)
    @notifier.ping msg if Rails.env.production?
  end
end