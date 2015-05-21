class User < ActiveRecord::Base
  has_many :records
  has_many :bookmarks

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["info"]["name"]
      user.email = auth["info"]["email"]
      user.image = auth["info"]["image"]
    end
  end

  def self.create_with_doorkeeper(auth)
    create! do |user|
      user.provider = "facebook"
      user.uid = auth["id"]
      user.name = "#{auth['first_name']} #{auth['last_name']}"
      user.email = auth["email"]
      user.image = "https://graph.facebook.com/#{auth['id']}/picture?type=square"
    end
  end
end
