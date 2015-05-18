class Record < ActiveRecord::Base
  before_create :generate_uuid!

  attr_accessor :bookmark

  belongs_to :user
  has_many :bookmark_histories
  mount_uploader :file, RecordUploader

  validates :title, presence: { message: "1자 이상으로 입력해주세요." }
  scope :remaining, -> { where(deleted: false) }

private
  def generate_uuid!
    self.uuid = SecureRandom.uuid
  end
end
