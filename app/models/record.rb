class Record < ActiveRecord::Base
  include SyncableModel

  scope :remaining, -> { where.not(file: nil) }
  scope :from_remote, -> { with_deleted.where.not(file: nil) }

  attr_accessor :bookmark

  belongs_to :user
  has_many :bookmark_histories
  mount_uploader :file, RecordUploader

  validates :title, presence: { message: "1자 이상으로 입력해주세요." }
end
