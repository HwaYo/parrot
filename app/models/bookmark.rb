class Bookmark < ActiveRecord::Base
  include SyncableModel

  belongs_to :user
  has_many :bookmark_histories, dependent: :destroy

  validates :name, presence: true
  validates :color, presence: true
end
