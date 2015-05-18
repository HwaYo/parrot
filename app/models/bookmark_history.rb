class BookmarkHistory < ActiveRecord::Base
  before_create :generate_uuid!

  belongs_to :bookmark
  belongs_to :record

private
  def generate_uuid!
    self.uuid = SecureRandom.uuid
  end
end
