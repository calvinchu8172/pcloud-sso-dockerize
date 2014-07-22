class ChangeEnabledFormateInPairing < ActiveRecord::Migration
  def change
  	change_column :pairings, :enabled, :boolean, {:default => true, :null=>false}
  end
end
