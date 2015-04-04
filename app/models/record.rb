class Record < ActiveRecord::Base
  belongs_to :user
  mount_uploader :file, RecordUploader
end
