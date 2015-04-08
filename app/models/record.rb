class Record < ActiveRecord::Base
  belongs_to :user
  mount_uploader :file, RecordUploader
  
  validates :title, presence: { message: "1자 이상으로 입력해주세요." }

  scope :remaining, -> { where(deleted: false) }
end
