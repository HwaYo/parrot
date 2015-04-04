class CreateRecords < ActiveRecord::Migration
  def change
    create_table :records do |t|
      t.string :title
      t.text :note
      t.text :bookmark
      t.string :file
      t.belongs_to :user, index: true
      t.timestamps null: false
    end
  end
end
