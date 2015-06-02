class Bookmark < ActiveRecord::Base
  include SyncableModel

  belongs_to :user, dependent: :destroy
  has_many :bookmark_histories

  validates :name, presence: true
  validates :color, presence: true
end
