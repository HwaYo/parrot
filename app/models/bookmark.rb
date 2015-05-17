class Bookmark < ActiveRecord::Base
  before_create :generate_uuid!

  belongs_to :user

  validates :name, presence: true
  validates :color, presence: true

private
  def generate_uuid!
    self.uuid = SecureRandom.uuid
  end
end
