class User < ActiveRecord::Base
  after_create :notify_slack

  has_many :records, dependent: :destroy
  has_many :bookmarks, dependent: :destroy

  def self.create_with_omniauth(auth)
    user = create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["info"]["name"]
      user.email = auth["info"]["email"]
      user.image = auth["info"]["image"]
    end

    create_bookmark!(user)
    user
  end

  def self.create_with_doorkeeper(auth)
    user = create! do |user|
      user.provider = "facebook"
      user.uid = auth["id"]
      user.name = "#{auth['first_name']} #{auth['last_name']}"
      user.email = auth["email"]
      user.image = "https://graph.facebook.com/#{auth['id']}/picture?type=square"
    end

    create_bookmark!(user)
    user
  end

private
  def self.create_bookmark!(user)
    [
      { name: 'Important', color: '#e11d21' },
      { name: "Don't Understand", color: '#fbca04' },
      { name: 'Not Important', color: '#207de5' }
    ].each { |attribute| user.bookmarks.create!(attribute) }
  end

  def notify_slack
    SlackNotificationJob.new.async.perform("New user from web: #{self.email} (#{self.uid})")
  end
end
