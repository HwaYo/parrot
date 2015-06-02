class PublishEventJob
  include SuckerPunch::Job

  def perform(key, object)
    Keen.publish(key, object) if Rails.env.production?
  end
end