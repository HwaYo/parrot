module SyncableModel
  extend ActiveSupport::Concern

  included do
    before_create :generate_uuid!
  end

  def generate_uuid!
    self.uuid = SecureRandom.uuid if self.uuid.nil?
  end
end