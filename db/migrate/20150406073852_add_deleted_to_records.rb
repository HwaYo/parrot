class AddDeletedToRecords < ActiveRecord::Migration
  def change
    add_column :records, :deleted, :boolean, :default => false
  end
end
