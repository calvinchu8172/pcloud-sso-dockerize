class AddPairingTypeToProduct < ActiveRecord::Migration
  def change
    add_column :products, :pairing_type, :string
  end
end
