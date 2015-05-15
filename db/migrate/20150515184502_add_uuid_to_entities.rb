class AddUuidToEntities < ActiveRecord::Migration
  def self.up
    add_column :records, :uuid, :string

    Record.transaction do
      Record.all.each do |record|
        record.uuid = SecureRandom.uuid
        record.save!
      end
    end
  end

  def self.down
    remove_column :records, :uuid
  end
end
