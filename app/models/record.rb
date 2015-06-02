class Record < ActiveRecord::Base
  include SyncableModel

  scope :remaining, -> { where.not(file: nil) }
  scope :from_remote, -> { with_deleted.where.not(file: nil) }

  attr_accessor :bookmark

  belongs_to :user
  has_many :bookmark_histories, dependent: :destroy
  mount_uploader :file, RecordUploader

  validates :title, presence: { message: "title has to be longer than 1 character" }
  validates :username, presence: { message: "username has to be longer than 1 character" }, if: :is_shared?
  validates :password, presence: { message: "password has to be longer than 1 character" }, if: :is_shared?

  def is_shared?
    share_token != nil
  end

  def share(params)
    if self.share_token == nil
      self.share_token = SecureRandom.hex[0,10]
    end
    self.username = params[:username]
    self.password = params[:password]
  end

  def stop_sharing
    self.share_token = nil
  end

end
