class AddDescriptionToCertificates < ActiveRecord::Migration
  def change
    add_column :certificates, :description, :string
  end
end
