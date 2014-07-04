class AddColumnEnabledToPairing < ActiveRecord::Migration
  def change
    add_column :pairings, :enabled, :integer, default: 1
  end
end
