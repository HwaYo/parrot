class Bookmark < ActiveRecord::Base
  belongs_to :user

  validates :name, presence: true
  validates :color, presence: true
end
