class AddAttachmentPairingToProducts < ActiveRecord::Migration
  def self.up
    change_table :products do |t|
      t.attachment :pairing
    end
  end

  def self.down
    drop_attached_file :products, :pairing
  end
end
