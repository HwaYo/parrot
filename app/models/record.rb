class Record < ActiveRecord::Base
  before_create :generate_uuid!

  belongs_to :user
  mount_uploader :file, RecordUploader

  validates :title, presence: { message: "1자 이상으로 입력해주세요." }
  scope :remaining, -> { where(deleted: false) }

private
  def generate_uuid!
    self.uuid = SecureRandom.uuid
  end
end
