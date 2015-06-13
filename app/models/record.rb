class Record < ActiveRecord::Base
  include SyncableModel

  scope :remaining, -> { where.not(file: nil) }
  scope :from_remote, -> { with_deleted.where.not(file: nil) }

  attr_reader :bookmark

  belongs_to :user
  has_many :bookmark_histories, dependent: :destroy
  mount_uploader :file, RecordUploader

  validates :title, presence: { message: "title has to be longer than 1 character" }
  validates :username, presence: { message: "username has to be longer than 1 character" }, if: :is_shared?
  validates :password, presence: { message: "password has to be longer than 1 character" }, if: :is_shared?

  before_save :build_histories

  def file_url
    if noise_reduced_file_url
      noise_reduced_file_url
    else
      file.try(:url)
    end
  end

  def bookmark=(value)
    @bookmark = JSON.parse(value) if String === value
  end

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

private
  def build_histories
    return if bookmark.nil?
    new_histories = bookmark.reject {|history| history.keys.include?('uuid') }
    new_histories.each do |history|
      bookmark = Bookmark.find_by_id(history['bookmark_id'])
      next if bookmark.nil?

      self.bookmark_histories.build(
        history.slice(*BookmarkHistory.column_names)
        .except('id')
        .merge(bookmark: bookmark)
      )
    end
  end
end
