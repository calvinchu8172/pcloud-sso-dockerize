class RenameCloumnInPairingSession < ActiveRecord::Migration
  def change
  	rename_column :pairing_sessions, :exprie_at, :expire_at
  end
end
