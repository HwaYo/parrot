class AddShareTokenToRecord < ActiveRecord::Migration
  def change
    add_column :records, :share_token, :string
    add_column :records, :password, :string
    add_column :records, :username, :string
  end
end
