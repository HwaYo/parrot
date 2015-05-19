class Record < ActiveRecord::Base
  include SyncableModel

  scope :remaining, -> { where(deleted: false).where.not(file: nil) }
  scope :from_remote, -> { where.not(file: nil) }

  attr_writer :bookmark

  belongs_to :user
  has_many :bookmark_histories
  mount_uploader :file, RecordUploader

  validates :title, presence: { message: "1자 이상으로 입력해주세요." }

  def bookmark
    @bookmark_histories ||= self[:bookmark].to_json
  end
end
