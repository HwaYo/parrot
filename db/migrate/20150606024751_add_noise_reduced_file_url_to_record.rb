class AddNoiseReducedFileUrlToRecord < ActiveRecord::Migration
  def change
    add_column :records, :noise_reduced_file_url, :string
  end
end
