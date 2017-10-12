class AddCreatedAtAndUpdatedAtToCertificates < ActiveRecord::Migration
  def change
    add_column :certificates, :created_at, :datetime, null: false
    add_column :certificates, :updated_at, :datetime, null: false
  end
end
